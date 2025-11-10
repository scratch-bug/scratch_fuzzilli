function F0(a2, a3, a4, a5) {
    if (!new.target) { throw 'must be called with new'; }
}
class C6 {
    static [F0](a8, a9, a10) {
        super[this] = this;
    }
}
try { C6.compare(C6); } catch (e) {}
C6[Int8Array] -= Symbol;
