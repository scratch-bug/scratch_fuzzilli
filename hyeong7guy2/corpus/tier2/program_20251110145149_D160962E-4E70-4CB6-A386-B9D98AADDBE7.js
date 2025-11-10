function F1() {
    if (!new.target) { throw 'must be called with new'; }
    this.a = 2147483647;
}
const v3 = new F1();
const v6 = new Uint16Array();
v3.a &&= 869;
[] = v6;
const v9 = new BigUint64Array(999);
const v11 = new Float64Array();
v9[101];
function F14(a16, a17) {
    if (!new.target) { throw 'must be called with new'; }
    const t13 = v11.constructor;
    new t13(Symbol);
}
new F14();
