function f0(a1, a2) {
    f0();
    return f0;
}
try { f0(f0, f0); } catch (e) {}
