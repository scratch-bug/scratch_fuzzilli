const v1 = new Uint8Array();
class C2 extends Uint8Array {
    static {
        try { new Uint8Array(this, this, ...this, this, this, ...v1); } catch (e) {}
    }
}
