// ICTransitionMutator.swift
// 기존에 막 생성된 객체의 첫 출력 변수만 대상으로 Map/shape 전이를 유도.

import Foundation

public class ICTransitionMutator: BaseInstructionMutator {
    public init() {
        super.init(name: "ICTransitionMutator", maxSimultaneousMutations: 3)
    }

    // 이 포크는 outputs/inouts가 Non-Optional ArraySlice 임.
    public override func canMutate(_ instr: Instruction) -> Bool {
        return instr.outputs.count > 0 || instr.inouts.count > 0 || instr.numOutputs > 0
    }

    public override func mutate(_ instr: Instruction, _ b: ProgramBuilder) {
        b.adopt(instr)

        guard let raw = firstOutput(of: instr) else { return }

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
