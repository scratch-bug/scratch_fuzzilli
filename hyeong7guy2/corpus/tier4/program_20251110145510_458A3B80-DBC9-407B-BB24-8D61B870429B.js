function F0() {
    if (!new.target) { throw 'must be called with new'; }
}
function f3() {
    return WeakMap;
}
Math.cbrt(2147483649);
f3();
%PrepareFunctionForOptimization(f3);
%OptimizeMaglevOnNextCall(f3);
f3();
