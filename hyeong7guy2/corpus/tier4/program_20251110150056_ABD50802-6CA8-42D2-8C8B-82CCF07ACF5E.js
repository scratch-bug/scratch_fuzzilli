function f0(a1, a2) {
    const v3 = a2.constructor;
    try { v3(a1); } catch (e) {}
    return f0;
}
const v6 = new Promise(f0);
const v7 = v6.constructor;
try { new v7(); } catch (e) {}
