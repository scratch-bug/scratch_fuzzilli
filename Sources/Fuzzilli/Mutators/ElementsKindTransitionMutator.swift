// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// Forces ElementsKind transitions in JavaScript arrays by applying
/// various mutations that cause type transitions (Smi -> Double -> Object,
/// Packed -> Holey, etc.)
public class ElementsKindTransitionMutator: BaseInstructionMutator {
    private var deadCodeAnalyzer = DeadCodeAnalyzer()
    private var variableAnalyzer = VariableAnalyzer()
    private var contextAnalyzer = ContextAnalyzer()
    private let minVisibleVariables = 1

    public init() {
        super.init(name: "ElementsKindTransitionMutator", maxSimultaneousMutations: 2)
    }

    public override func beginMutation(of program: Program) {
        deadCodeAnalyzer = DeadCodeAnalyzer()
        variableAnalyzer = VariableAnalyzer()
        contextAnalyzer = ContextAnalyzer()
    }

    public override func canMutate(_ instr: Instruction) -> Bool {
        deadCodeAnalyzer.analyze(instr)
        variableAnalyzer.analyze(instr)
        contextAnalyzer.analyze(instr)
        
        // Don't mutate in dead code
        guard !deadCodeAnalyzer.currentlyInDeadCode else {
            return false
        }
        
        // Need JavaScript context for array operations
        guard contextAnalyzer.context.contains(.javascript) else {
            return false
        }
        
        // Need at least some visible variables to work with arrays
        guard variableAnalyzer.visibleVariables.count >= minVisibleVariables else {
            return false
        }
        
        // Target array creation, but ALSO array element access/setting operations
        // to catch IC/guard violations during element access after transitions
        return instr.op is CreateIntArray ||
               instr.op is CreateFloatArray ||
               instr.op is CreateArray ||
               instr.op is GetElement ||
               instr.op is SetElement
    }


    public override func mutate(_ instr: Instruction, _ b: ProgramBuilder) {
        // Case 1: Array creation - inject transition IMMEDIATELY after creation
        if instr.op is CreateIntArray || instr.op is CreateFloatArray || instr.op is CreateArray {
            // Always adopt the array first
            
            guard instr.outputs.count >= 1 else {  
                // b.adopt(instr)
                return
            }

            let parentOut = instr.outputs.first!

            b.adopt(instr)
            // Get the adopted variable
            let arrayVar = b.adopt(parentOut)

            b.trace("EKS: Injecting ElementsKind transition after array creation")

            switch roll(7) {
            case 0:
                injectDoubleTransition(using: b, arrayVar)
            case 1:
                injectObjectTransition(using: b, arrayVar)
            case 2:
                injectHoleyTransition(using: b, arrayVar)
            case 3:
                injectBigIntTransition(using: b, arrayVar)
            case 4:
                injectSpecialValues(using: b, arrayVar)
            case 5:
                injectLengthManipulation(using: b, arrayVar)
            // case 6:
            //     injectDeletePopTransition(using: b, arrayVar)
            default:
                break
            }

            // 시그니처를 실제 소비해서 JS에 남김
            // let sig = b.loadString("EKS_SIG_ArrayCreation")
            // let sigArr = b.createArray(with: [sig])
            // _ = b.createNamedVariable("eks_sig_marker", declarationMode: .var, initialValue: sigArr)
            
        // Case 2: Array element access - inject transition BEFORE access
        // This catches IC/guard violations when accessing elements after transition
        } else if instr.op is GetElement || instr.op is SetElement {
            // For GetElement: inputs are [array, index]
            // For SetElement: inputs are [array, index, value]
            // The array is the first input
            guard instr.inputs.count >= 1 else { b.adopt(instr); return }
            let recv0 = instr.input(0)
            let arrayVar = b.adopt(recv0)
            
            b.trace("EKS: Injecting ElementsKind transition before element access")

            // Inject transition before the access (다음 접근들에 영향)
            switch roll(7) {
            case 0:
                injectDoubleTransition(using: b, arrayVar)
            case 1:
                injectObjectTransition(using: b, arrayVar)
            case 2:
                injectHoleyTransition(using: b, arrayVar)
            case 3:
                injectBigIntTransition(using: b, arrayVar)
            case 4:
                injectSpecialValues(using: b, arrayVar)
            case 5:
                injectLengthManipulation(using: b, arrayVar)
            case 6:
                injectDeletePopTransition(using: b, arrayVar)
            default:
                break
            }

            b.adopt(instr)
            return
            
            // 시그니처를 실제 소비해서 JS에 남김
            // let sig = b.loadString("EKS_SIG_ElementAccess")
            // let sigArr = b.createArray(with: [sig])
            // _ = b.createNamedVariable("eks_sig_marker", declarationMode: .var, initialValue: sigArr)
        } else {
            // Fallback
            b.adopt(instr)
        }
    }

    // 1. Smi → Double transition
    private func injectDoubleTransition(using b: ProgramBuilder, _ arrayVar: Variable) {
        b.trace("EKS: Injecting Double transition")
        let floatVal = b.loadFloat(1.5)
        b.callMethod("push", on: arrayVar, withArgs: [floatVal])
    }

    // 2. Object transition
    private func injectObjectTransition(using b: ProgramBuilder, _ arrayVar: Variable) {
        b.trace("EKS: Injecting Object transition")
        // Push an empty object
        let obj = b.createObject(with: [:])
        b.callMethod("push", on: arrayVar, withArgs: [obj])
    }

    // 3. Holey transition: delete element or large index
    private func injectHoleyTransition(using b: ProgramBuilder, _ arrayVar: Variable) {
        b.trace("EKS: Injecting Holey transition")
        let val = b.loadInt(42)
        b.setElement(0x100000, of: arrayVar, to: val)
    }

    // 4. BigInt transition
    private func injectBigIntTransition(using b: ProgramBuilder, _ arrayVar: Variable) {
        b.trace("EKS: Injecting BigInt transition")
        let bigInt = b.loadBigInt(42)
        b.callMethod("push", on: arrayVar, withArgs: [bigInt])
    }

    // 5. NaN/Infinity
    private func injectSpecialValues(using b: ProgramBuilder, _ arrayVar: Variable) {
        b.trace("EKS: Injecting special values")
        let special = probability(0.5) ? b.loadFloat(Double.nan) : 
                     (probability(0.5) ? b.loadFloat(Double.infinity) : 
                      b.loadFloat(-Double.infinity))
        b.callMethod("push", on: arrayVar, withArgs: [special])
    }

    // 6. Length manipulation
    private func injectLengthManipulation(using b: ProgramBuilder, _ arrayVar: Variable) {
        b.trace("EKS: Injecting length manipulation")
        if probability(0.5) {
            // Truncate array
            let newLength = b.loadInt(1)
            b.setProperty("length", of: arrayVar, to: newLength)
        } else {
            // Extend with holes
            let newLength = b.loadInt(100)
            b.setProperty("length", of: arrayVar, to: newLength)
        }
    }

    // 7. Delete/Pop transition: remove elements using pop, shift, or delete
    private func injectDeletePopTransition(using b: ProgramBuilder, _ arrayVar: Variable) {
        b.trace("EKS: Injecting delete/pop transition")
        switch roll(4) {
        case 0:
            // Pop last element
            _ = b.callMethod("pop", on: arrayVar, withArgs: [])
        case 1:
            // Shift first element
            _ = b.callMethod("shift", on: arrayVar, withArgs: [])
        case 2:
            // Delete element at index 0
            _ = b.deleteElement(0, of: arrayVar)
        case 3:
            // Delete element at random small index
            let index = Int64.random(in: 0..<10)
            _ = b.deleteElement(index, of: arrayVar)
        default:
            break
        }
    }

    // Utility: roll dice
    private func roll(_ sides: Int) -> Int {
        return Int.random(in: 0..<sides)
    }
}
