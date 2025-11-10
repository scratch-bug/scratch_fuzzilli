const v2 = {};
function F3(a5, a6) {
    if (!new.target) { throw 'must be called with new'; }
    try {
    const t0 = "string";
    t0(Symbol, Symbol);
    } catch (e) {}
}
new F3();
