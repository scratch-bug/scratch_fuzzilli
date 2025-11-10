class C1 extends Set {
}
const v2 = new C1();
const v5 = SharedArrayBuffer.prototype.grow;
try { v5.apply(v2); } catch (e) {}
