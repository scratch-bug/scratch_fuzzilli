const v0 = [1000000000000.0];
class C1 {
}
class C2 extends C1 {
    static [C1](a4, a5, a6, a7) {
    }
    [v0];
}
new C2();
for (let i = 0; i < 5; i++) {
    Object.defineProperty(C1, 222, { value: C2 });
}
