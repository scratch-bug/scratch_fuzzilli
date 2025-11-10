function F0(a2) {
    if (!new.target) { throw 'must be called with new'; }
}
const v3 = [F0];
for (let i = 0; i < 5; i++) {
    Object.defineProperty(v3, 1, { writable: true, enumerable: true, value: v3 });
}
