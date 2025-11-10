function f0() {
}
const t2 = [846.8084269697188,1.0,2.2250738585072014e-308,NaN,0.0,1.7976931348623157e+308];
t2[9] = Float64Array;
%PrepareFunctionForOptimization(f0);
%OptimizeMaglevOnNextCall(f0);
f0();
