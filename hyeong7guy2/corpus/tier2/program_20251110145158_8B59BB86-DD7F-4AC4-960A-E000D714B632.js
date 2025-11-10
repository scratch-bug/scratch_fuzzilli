function F0() {
    if (!new.target) { throw 'must be called with new'; }
    this.h = this;
    this.e = -12;
    this.d = -12;
    this.h = -12;
}
new F0();
const v6 = new Uint16Array(2325);
function F8(a10, a11) {
    if (!new.target) { throw 'must be called with new'; }
    this.constructor = Symbol;
    const v12 = this.constructor;
    try { new v12(v12, a11); } catch (e) {}
}
new F8(F8, v6);
