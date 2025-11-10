function F1(a3, a4) {
    if (!new.target) { throw 'must be called with new'; }
    this.a = a4;
}
new F1(F1, -5.173281472174841e+307);
new F1();
