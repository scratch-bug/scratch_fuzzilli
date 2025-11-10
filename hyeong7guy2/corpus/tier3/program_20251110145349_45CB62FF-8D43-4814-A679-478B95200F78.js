const v7 = {
    [Symbol]() {
        const v6 = {
            next() {
                return {};
            },
        };
    },
};
function f9() {
    return f9;
}
function f11() {
    const v14 = Symbol.dispose;
    const v21 = {
        [v14](a16, a17, a18) {
            try {
                super.o(v14, a18, f9);
            } catch(e20) {
            }
        },
    };
    using v22 = v21;
    return v22;
}
f11();
