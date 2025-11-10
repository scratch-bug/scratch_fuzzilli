function F1(a3, a4) {
    if (!new.target) { throw 'must be called with new'; }
    const v5 = this.constructor;
    try { new v5(this, a3); } catch (e) {}
    this.a = a4;
}
new F1(F1, 9);
