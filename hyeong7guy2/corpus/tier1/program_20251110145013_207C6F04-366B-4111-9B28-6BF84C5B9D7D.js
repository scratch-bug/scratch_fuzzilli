const v2 = class {
    #m(a4, a5) {
        %PretenureAllocationSite(this);
        return this;
    }
    static [-1] = 824.3760860521948;
}
const v6 = new v2();
function F8(a10, a11, a12, a13) {
    if (!new.target) { throw 'must be called with new'; }
    this.e = a10;
}
const v14 = new F8(512, v6, 824.3760860521948, F8);
const v15 = new F8(824.3760860521948, 824.3760860521948, v14, 34614);
const v16 = new F8(34614, v15, v6, 824.3760860521948);
[v16,v14];
try {
    v14.p(v2, v15);
} catch(e19) {
}
const v20 = (a21, a22) => {
    const v24 = Symbol.dispose;
    const v28 = {
        [v24](a26, a27) {
            super[v2] = v15;
        },
    };
    using v29 = v28;
};
