function f0() {
    return f0;
}
class C2 {
    [-9223372036854775807];
}
const v3 = new C2();
Reflect.construct(C2, [v3,v3,v3], f0);
