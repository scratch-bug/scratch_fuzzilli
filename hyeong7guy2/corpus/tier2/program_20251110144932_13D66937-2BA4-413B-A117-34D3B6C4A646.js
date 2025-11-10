function F2(a4, a5, a6, a7) {
    if (!new.target) { throw 'must be called with new'; }
    this.g = a5;
    this.a = 0.0;
}
const v8 = new F2(undefined, 0.0);
new F2(v8, v8);
const v13 = {
    o(a11, a12) {
        return this;
    },
};
