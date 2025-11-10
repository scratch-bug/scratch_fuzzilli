function f1() {
    return Int8Array;
}
f1();
%PrepareFunctionForOptimization(f1);
%OptimizeFunctionOnNextCall(f1);
f1();
