// ICTransitionMutator.swift
// 기존에 막 생성된 객체의 첫 출력 변수만 대상으로 Map/shape 전이를 유도.

import Foundation

public class ICTransitionMutator: BaseInstructionMutator {
    private var deadCodeAnalyzer = DeadCodeAnalyzer()
    private var variableAnalyzer = VariableAnalyzer()
    private var contextAnalyzer = ContextAnalyzer()
    private let minVisibleVariables = 1

    public init() {
        super.init(name: "ICTransitionMutator", maxSimultaneousMutations: 3)
    }

    public override func beginMutation(of program: Program) {
        deadCodeAnalyzer = DeadCodeAnalyzer()
        variableAnalyzer = VariableAnalyzer()
        contextAnalyzer = ContextAnalyzer()
    }

    // Target object/array creation and access operations that benefit from IC transition mutations
    public override func canMutate(_ instr: Instruction) -> Bool {
        deadCodeAnalyzer.analyze(instr)
        variableAnalyzer.analyze(instr)
        contextAnalyzer.analyze(instr)
        
        // Don't mutate in dead code
        guard !deadCodeAnalyzer.currentlyInDeadCode else {
            return false
        }
        
        // Need JavaScript context for object operations
        guard contextAnalyzer.context.contains(.javascript) else {
            return false
        }
        
        // Need at least some visible variables to work with objects
        guard variableAnalyzer.visibleVariables.count >= minVisibleVariables else {
            return false
        }
        
        // Target object/array creation operations
        if instr.op is EndObjectLiteral ||
           instr.op is Construct ||
           instr.op is CreateArray ||
           instr.op is CreateIntArray ||
           instr.op is CreateFloatArray ||
           instr.op is CreateArrayWithSpread {
            return instr.outputs.count > 0 || instr.numOutputs > 0
        }
        
        // Target object/array access operations that can trigger IC transitions
        if instr.op is GetProperty ||
           instr.op is SetProperty ||
           instr.op is GetElement ||
           instr.op is SetElement ||
           instr.op is CallMethod {
            return instr.inputs.count > 0
        }
        
        return false
    }

    public override func mutate(_ instr: Instruction, _ b: ProgramBuilder) {
        b.adopt(instr)

        // For creation operations, use the output (the created object/array)
        // For access operations, use the first input (the accessed object/array)
        let raw: Variable?
        if instr.op is EndObjectLiteral ||
           instr.op is Construct ||
           instr.op is CreateArray ||
           instr.op is CreateIntArray ||
           instr.op is CreateFloatArray ||
           instr.op is CreateArrayWithSpread {
            raw = firstOutput(of: instr)
        } else if instr.op is GetProperty ||
                  instr.op is SetProperty ||
                  instr.op is GetElement ||
                  instr.op is SetElement ||
                  instr.op is CallMethod {
            // For access operations, the first input is the object/array
            raw = instr.inputs.count > 0 ? instr.input(0) : nil
        } else {
            raw = nil
        }

        guard let raw = raw else { return }
        let obj = b.adopt(raw)

        switch Int.random(in: 0..<3) {
        case 0:
            createInsertionOrderVariants(obj, b)
        case 1:
            addAndRemoveProps(obj, b)
        case 2:
            forceDictionaryMode(obj, b)
        default:
            break
        }

        hotAccessBurst(obj, "p_stable", b)
    }

    // --- 첫 번째 출력 변수 취득: outputs.first → inouts.first 순으로만 사용 ---
    func firstOutput(of instr: Instruction) -> Variable? {
        if let v = instr.outputs.first { return v }
        if let v = instr.inouts.first { return v }
        return nil
    }

    // --- 전이 동작들: 새 객체 생성 없이 obj에만 적용 ---

    func createInsertionOrderVariants(_ obj: Variable, _ b: ProgramBuilder) {
        let rounds = Int.random(in: 1...3)
        let code = """
        (function(o, rounds){
        for (let seed = 0; seed < rounds; seed++) {
            o["a"+seed] = ((seed*997)|0)+1;
            o["b"+seed] = ((seed*997)|0)+2;
            o["c"+seed] = ((seed*997)|0)+3;
            o["d"+seed] = ((seed*997)|0)+4;
            if ((seed & 1) === 0) { delete o["b"+seed]; o.p_stable; o["b"+seed] = seed|0; }
            o.p_stable;
        }
        })(%@, \(rounds))
        """
        b.eval(code, with: [obj])
    }

    func addAndRemoveProps(_ obj: Variable, _ b: ProgramBuilder) {
        let rounds = Int.random(in: 4...12)
        let code = """
        (function(o, rounds){
        for (let r = 0; r < rounds; r++) {
            const base = ((Math.imul(r, 1103515245) + 12345)>>>0) % 10000;
            for (let i = 0; i < 6; i++) {
            const k = "p_"+r+"_"+i+"_"+base;
            o[k] = (r*100 + i)|0;
            if ((i & 1) === 0) delete o[k];
            }
            if ((r % 3) === 0) {
            const k = "p_"+r+"_0_"+base;
            o[k] = r|0;
            }
            if ((r % 7) === 0) {
            const rb = (((base>>>8) + r)>>>0) % 10000;
            for (let k = 4; k >= 0; k--) {
                o["reorder_"+r+"_"+k+"_"+rb] = k|0;
            }
            }
            o.p_stable;
        }
        })(%@, \(rounds))
        """
        b.eval(code, with: [obj])
    }

    func forceDictionaryMode(_ obj: Variable, _ b: ProgramBuilder) {
        let count = Int.random(in: 20...70)
        let code = """
        (function(o, n){
        for (let i = 0; i < n; i++) {
            const k = "dict_"+i+"_"+(((Math.imul(i, 2654435761)>>>0)) % 10000);
            o[k] = i|0;
            if ((i % 5) === 0 && (((Math.imul(i, 1664525) + 1013904223)>>>0) % 10) < 3) delete o[k];
            if ((i % 13) === 0) { o.__flip = 1; o.p_stable; delete o.__flip; }
        }
        })(%@, \(count))
        """
        b.eval(code, with: [obj])
    }

    func hotAccessBurst(_ obj: Variable, _ prop: String, _ b: ProgramBuilder) {
        let burst = Int.random(in: 40...120)
        let code = "(function(o){for(let i=0;i<\(burst);i++){o.\(prop);}})(%@)"
        b.eval(code, with: [obj])
    }

    }
