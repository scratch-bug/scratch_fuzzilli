function F1(a3, a4, a5) {
    if (!new.target) { throw 'must be called with new'; }
    this.b = 11;
    this.f = a3;
}
const v6 = new F1();
for (const v7 in v6) {
}
