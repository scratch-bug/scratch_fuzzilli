async function f0(a1, a2) {
    try { a1(); } catch (e) {}
    const v5 = Symbol();
    const v6 = Symbol.asyncDispose;
    const v15 = {
        [v6](a8, a9) {
            for (let v10 = 0; v10 < 100; v10++) {
            }
            const v13 = ArrayBuffer.prototype.resize;
            try { v13.call(v5); } catch (e) {}
        },
    };
    await using v16 = v15;
}
f0(f0);
