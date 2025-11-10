const v2 = new Float32Array(3763);
new WeakMap();
const v9 = new Array(129);
const v11 = [3763,129,WeakMap,v2,v2];
function F12(a14, a15, a16, a17) {
    if (!new.target) { throw 'must be called with new'; }
    this.b = a17;
    this.d = a16;
}
new F12(129, Array, F12, 129);
new F12(5.0, v11, v11, Float32Array);
const t11 = gc();
let v22 = delete t11?.[gc];
v22 = 5.0;
new Date();
with (v9) {
    for (let i30 = 0, i31 = 10; i30 < i31; i30++, i31--) {
        let v40 = 0;
        do {
            Object.defineProperty(Array, "h", { writable: true, value: v22 });
            Date(5.0);
            %PrepareFunctionForOptimization(Date);
            Date(5.0);
            Date(5.0);
            %OptimizeMaglevOnNextCall(Date);
            Date(5.0);
            v40++;
        } while (v40 < 3)
    }
}
