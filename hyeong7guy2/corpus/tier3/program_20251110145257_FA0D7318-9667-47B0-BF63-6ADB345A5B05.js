const v3 = Symbol.iterator;
const v5 = {
    [v3]() {
    },
};
const v7 = {
    [-21450n]() {
    },
};
const v9 = {
    [Symbol]() {
    },
};
function F10(a12, a13) {
    if (!new.target) { throw 'must be called with new'; }
    const v14 = this?.constructor;
    (2n).length;
    try { new v14(); } catch (e) {}
    this.g = a13;
}
new F10();
new F10();
