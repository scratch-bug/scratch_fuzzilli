function f0() {
    return f0;
}
class C1 {
}
const v2 = new C1();
const v3 = new C1();
class C4 extends f0 {
    static [v3](a6, a7) {
    }
    static [v2](a9, a10, a11) {
    }
}
new C4();
function f13(a14) {
    return C4;
}
const v15 = class extends f13 {
}
f13();
%PrepareFunctionForOptimization(f13);
%OptimizeFunctionOnNextCall(f13);
f13();
