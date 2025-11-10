function F1(a3) {
    if (!new.target) { throw 'must be called with new'; }
    this.h = Set;
    this.e = a3;
    this.a = a3;
}
const v4 = new F1(F1);
v4.__proto__ = Int8Array;
