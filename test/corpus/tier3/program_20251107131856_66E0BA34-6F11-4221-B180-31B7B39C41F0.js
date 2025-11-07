function f0() {
    const v1 = [];
    v1[8] = 4.2;
    for (let i5 = 0; i5 < 5; i5++) {
        let v4 = v1[4];
        for (let i14 = 0; i14 < 5; i14++) {
            i5 = v4;
            try {
                v4.n();
            } catch(e21) {
            }
            ++v4;
        }
    }
}
const v23 = %PrepareFunctionForOptimization(f0);
f0();
const v25 = %OptimizeFunctionOnNextCall(f0);
f0();
