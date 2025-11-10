function f0() {
    return f0;
}
class C1 {
}
let v2 = f0.bind();
function f3(a4) {
    return v2;
}
class C5 extends f3 {
    static [v2] = C1;
}
