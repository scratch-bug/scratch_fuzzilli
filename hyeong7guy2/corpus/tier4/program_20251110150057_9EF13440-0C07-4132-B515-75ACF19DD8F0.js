function F0(a2) {
    if (!new.target) { throw 'must be called with new'; }
}
const v4 = F0[1];
try { v4.__proto__ = 0; } catch (e) {}
