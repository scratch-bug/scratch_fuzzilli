function F0() {
    if (!new.target) { throw 'must be called with new'; }
    this.d = 536870912;
}
new F0();
const v4 = new F0();
new F0();
new F0();
const v8 = Symbol.iterator;
const v17 = {
    [v8]() {
        let v10 = 10;
        const v16 = {
            next() {
                v10--;
                const v14 = v10 == 0;
                return { done: v14, value: v10 };
            },
        };
        return v16;
    },
};
[v4];
class C19 {
    o(a21, a22) {
        a22[127] = a21;
        return a21;
    }
    [F0](a24, a25, a26, a27) {
        return a25;
    }
}
new C19();
gc({ execution: "sync", type: "minor" });
const t33 = Intl.NumberFormat;
new t33("ha");
