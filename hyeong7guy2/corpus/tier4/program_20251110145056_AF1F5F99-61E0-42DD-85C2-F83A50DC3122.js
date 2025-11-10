async function f0(a1, a2) {
    const v4 = Symbol.asyncDispose;
    const v8 = {
        [v4](a6, a7) {
        },
    };
    await using v9 = v8;
    return v9;
}
f0(f0, f0);
