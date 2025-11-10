function F2(a4, a5) {
    if (!new.target) { throw 'must be called with new'; }
    (15).prototype;
    try { new this(); } catch (e) {}
}
new F2();
new F2();
