class C1 {
    static {
        const v4 = class extends this.constructor {
        }
        new v4();
    }
}
const v8 = ArrayBuffer.prototype.slice;
try { v8.apply(-1e-15); } catch (e) {}
