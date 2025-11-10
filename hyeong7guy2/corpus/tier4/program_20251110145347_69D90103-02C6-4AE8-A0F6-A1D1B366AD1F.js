const v1 = [15,15,15,15,15];
try { v1(); } catch (e) {}
async function* f3(a4, a5, a6, a7) {
    const v9 = await (yield a4);
    yield* [v9,v9];
    return 15;
}
