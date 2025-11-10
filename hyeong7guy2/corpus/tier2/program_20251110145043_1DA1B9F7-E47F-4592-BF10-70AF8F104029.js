class C2 {
    static {
        this[1073741824];
    }
}
const v7 = {
    [Symbol]() {
    },
};
function F8(a10, a11) {
    if (!new.target) { throw 'must be called with new'; }
    this.g = a11;
}
new F8("a", C2);
new F8("string", v7);
