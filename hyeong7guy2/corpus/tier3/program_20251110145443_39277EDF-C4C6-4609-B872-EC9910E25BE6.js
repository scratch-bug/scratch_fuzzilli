const v1 = Array(Array);
function f3() {
    return Array;
}
const v4 = { [1433130714n]: v1 };
f3();
%PrepareFunctionForOptimization(f3);
%OptimizeFunctionOnNextCall(f3);
f3();
