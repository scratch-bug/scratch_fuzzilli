function F0(a2, a3) {
    if (!new.target) { throw 'must be called with new'; }
    function F4(a6, a7) {
        if (!new.target) { throw 'must be called with new'; }
        const v10 = Date.prototype.getTime;
        try { v10.call(); } catch (e) {}
    }
    new F4(F0, F0);
}
new F0();
