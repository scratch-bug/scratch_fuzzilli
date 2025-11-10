function F1() {
    if (!new.target) { throw 'must be called with new'; }
    this.c = -2n;
}
new F1();
class C4 {
    #valueOf(a6, a7) {
        a6.#valueOf();
    }
}
class C9 extends F1 {
}
new C9();
