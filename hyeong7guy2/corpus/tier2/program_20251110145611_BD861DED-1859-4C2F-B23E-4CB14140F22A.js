const v0 = /RF1foo(?=bar)baz()/ysvi;
for (let i = 0; i < 5; i++) {
    Object.defineProperty(Array, 2264, { configurable: true, enumerable: true, set: Array });
    const v2 = `p`;
    try {
        v2.matchAll(v0);
    } catch(e4) {
    }
}
