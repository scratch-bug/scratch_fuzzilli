function f1(a2, a3, a4, a5) {
    const v6 = Symbol.dispose;
    const v12 = {
        [v6](a8, a9, a10, a11) {
            super[v6] = a10;
        },
    };
    using v13 = v12;
    return f1;
}
f1(Symbol, f1, f1, Symbol);
