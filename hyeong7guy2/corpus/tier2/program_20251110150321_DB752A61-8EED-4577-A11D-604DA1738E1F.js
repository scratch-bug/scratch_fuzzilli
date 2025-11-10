function F0() {
    if (!new.target) { throw 'must be called with new'; }
}
const v5 = new Proxy(F0, {});
v5[8] %= WeakSet;
