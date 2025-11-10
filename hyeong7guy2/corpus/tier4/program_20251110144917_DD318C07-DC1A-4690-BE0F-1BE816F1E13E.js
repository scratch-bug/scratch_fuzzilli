function F0() {
    if (!new.target) { throw 'must be called with new'; }
}
const v2 = new F0();
function F3(a5, a6) {
    if (!new.target) { throw 'must be called with new'; }
}
new F3(F3, v2);
const v9 = Symbol.toPrimitive;
const v11 = {
    [v9]() {
    },
};
