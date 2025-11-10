class C0 {
    static get h() {
        super.g = this;
    }
}
try { C0["p"](); } catch (e) {}
