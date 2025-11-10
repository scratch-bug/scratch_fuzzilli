class C1 extends WeakSet {
}
const v2 = new C1();
const v3 = new C1();
const v4 = [v3,WeakSet];
class C5 extends WeakSet {
    static [v4](a7, a8, a9, a10) {
    }
}
v2[65535] ??= C1;
