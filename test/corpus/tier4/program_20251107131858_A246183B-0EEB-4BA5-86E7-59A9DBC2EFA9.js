const v0 = {};
function f1() {
}
f1.prototype = v0;
const v2 = new f1();
obj = v2;
v0[Symbol.toStringTag] = "foo";
v2.toString(f1);
