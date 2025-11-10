function F0(a2, a3) {
    if (!new.target) { throw 'must be called with new'; }
    function F4() {
        if (!new.target) { throw 'must be called with new'; }
        const v6 = this.constructor;
        try { new v6(); } catch (e) {}
        this.h = this;
        this.e = -12;
        this.h = -12;
    }
    new F4();
    const v12 = new Uint16Array(2325);
    v12.toLocaleString();
    function F14(a16, a17) {
        if (!new.target) { throw 'must be called with new'; }
        Date.now();
    }
    new F14();
}
new F0();
new F0();
