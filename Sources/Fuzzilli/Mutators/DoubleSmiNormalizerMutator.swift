import Foundation

public class DoubleSmiNormalizerMutator: BaseInstructionMutator {
    public init() {
        super.init(name: "DoubleSmiNormalizerMutator", maxSimultaneousMutations: 3)
    }

    public override func canMutate(_ instr: Instruction) -> Bool {
        // 단일 출력 => 대부분 Load등의 정의형에서
        if instr.outputs.count != 1 { return false }
        return instr.op is LoadInteger || instr.op is LoadFloat || instr.op is LoadBigInt
    }

    public override func mutate(_ instr: Instruction, _ b: ProgramBuilder) {
        b.trace("DSM: mutating \(instr.op.name)")

        guard instr.outputs.count == 1 else {
            b.adopt(instr)
            return
        }

        if let loadInt = instr.op as? LoadInteger {
            let v = loadInt.value
            switch roll(100) {
            case 0..<45:
                // Smi to Double
                let d = Double(v) + 0.5
                b.adopt(Instruction(LoadFloat(value: d), inouts: instr.inouts, flags: instr.flags))
            case 45..<60:
                // NaN
                b.adopt(Instruction(LoadFloat(value: .nan), inouts: instr.inouts, flags: instr.flags))
            case 60..<70:
                // Infinity or -Infinity
                let inf = probability(0.5) ? Double.infinity : -Double.infinity
                b.adopt(Instruction(LoadFloat(value: inf), inouts: instr.inouts, flags: instr.flags))
            default:
                // Smi to BigInt
                let bi = Int64(clamping: v)
                b.adopt(Instruction(LoadBigInt(value: bi), inouts: instr.inouts, flags: instr.flags))
            }

        } else if let loadFloat = instr.op as? LoadFloat {
            let x = loadFloat.value
            switch roll(100) {
            case 0..<45:
                // Double to Smi
                let r = x.rounded(.toNearestOrAwayFromZero)
                let snapped: Int64
                if r.isFinite, r >= -1_000_000, r <= 1_000_000 { snapped = Int64(r) } else { snapped = 0 }
                b.adopt(Instruction(LoadInteger(value: snapped), inouts: instr.inouts, flags: instr.flags))
            case 45..<60:
                // NaN
                b.adopt(Instruction(LoadFloat(value: .nan), inouts: instr.inouts, flags: instr.flags))
            case 60..<70:
                // Infinity or -Infinity
                let inf = probability(0.5) ? Double.infinity : -Double.infinity
                b.adopt(Instruction(LoadFloat(value: inf), inouts: instr.inouts, flags: instr.flags))
            default:
                // Double to BigInt
                let r = x.rounded(.towardZero)
                let bi = (r.isFinite && abs(r) <= 9.22e18) ? Int64(r) : 0
                b.adopt(Instruction(LoadBigInt(value: bi), inouts: instr.inouts, flags: instr.flags))
            }

        } else if let loadBI = instr.op as? LoadBigInt {
            let bi = loadBI.value
            switch roll(100) {
            case 0..<50:
                // BigInt to Double
                let d = Double(bi)
                b.adopt(Instruction(LoadFloat(value: d + 0.5), inouts: instr.inouts, flags: instr.flags))
            case 50..<70:
                // BigInt to Smi
                let i = Int64(clamping: bi)
                b.adopt(Instruction(LoadInteger(value: i), inouts: instr.inouts, flags: instr.flags))
            default:
                // BigInt to NaN, Infinity, or -Infinity
                let pick = roll(3)
                let d: Double = (pick == 0 ? .nan : (pick == 1 ? .infinity : -.infinity))
                b.adopt(Instruction(LoadFloat(value: d), inouts: instr.inouts, flags: instr.flags))
            }

        } else {
            b.adopt(instr)
        }
    }
}

@inline(__always)
private func roll(_ n: Int) -> Int {
    return Int.random(in: 0..<n)
}
