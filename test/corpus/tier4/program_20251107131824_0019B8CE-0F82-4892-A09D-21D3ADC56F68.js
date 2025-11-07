for (let v0 = 0; v0 < 25; v0++) {
    const v3 = { a: 1, b: 2 };
    try { structuredClone(undefined, 1, 1, 2); } catch (e) {}
}
const v7 = {};
for (let v8 = 0; v8 < 25; v8++) {
    v7["p" + v8] = 0;
}
v7.a = v7;
