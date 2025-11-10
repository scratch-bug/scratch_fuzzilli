const v2 = ("symbol").normalize("NFC");
function f3() {
    return v2;
}
const v6 = new BigUint64Array(5);
function F7(a9, a10, a11) {
    if (!new.target) { throw 'must be called with new'; }
    this.b = 5;
}
const v13 = {
    __proto__: v6,
    get e() {
        return "NFC";
    },
};
%PrepareFunctionForOptimization(f3);
f3();
%OptimizeMaglevOnNextCall(f3);
f3();
