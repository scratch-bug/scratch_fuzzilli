const iterationCount = 10;
function test() {
    let trueValues = 0;
    let falseValues = 0;
    for (let i8 = 0; i8 < iterationCount; i8++) {
        var c2 = Math.floor(Math.random() * 10) + 100;
        if (!(!(!(!(!((c2 === 32) | (c2 === 34))) | (c2 === 92))))) {
            trueValues++;
        } else {
            falseValues++;
        }
    }
    return [trueValues,falseValues];
}
const v37 = %PrepareFunctionForOptimization(test);
print([iterationCount,0], test());
const v43 = %OptimizeFunctionOnNextCall(test);
print([iterationCount,0], test());
