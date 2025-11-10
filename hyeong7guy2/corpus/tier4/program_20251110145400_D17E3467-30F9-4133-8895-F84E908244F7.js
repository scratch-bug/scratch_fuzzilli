function F0() {
    if (!new.target) { throw 'must be called with new'; }
    try { new BigInt64Array(BigInt64Array); } catch (e) {}
    try {
        Map();
    } catch(e6) {
        e6.stack;
    }
}
const v8 = new F0();
new F0();
const v11 = new BigInt64Array(v8, F0);
v11.entries();
