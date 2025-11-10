function f0() {
}
class C2 extends WeakSet {
}
const t4 = [C2];
t4.__proto__ = C2;
%PrepareFunctionForOptimization(f0);
%OptimizeMaglevOnNextCall(f0);
f0();
%PrepareFunctionForOptimization(f0);
%OptimizeMaglevOnNextCall(f0);
