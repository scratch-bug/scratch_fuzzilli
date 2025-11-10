const v0 = class {
}
function f1() {
    return f1;
}
class C2 extends f1 {
    static set d(a4) {
        super.a = v0;
    }
}
try {
    C2.splice();
} catch(e6) {
}
