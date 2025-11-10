function F2(a4, a5) {
    if (!new.target) { throw 'must be called with new'; }
    const v6 = this.constructor;
    try { new v6(); } catch (e) {}
    this.a = a5;
}
const v8 = F2.constructor;
v8(9);
const v10 = new F2();
new F2(v10, v8);
class C14 {
    static #n(a16, a17) {
        Math.atan(5);
        Math.asin(a16);
        Math.hypot(a16);
        Math.max(5);
        Math.log2(17094n);
    }
}
function f25() {
    return C14;
}
function* f27(a28, a29, a30) {
    yield a29;
    [a30,a29,`ytuk`];
    return f25;
}
