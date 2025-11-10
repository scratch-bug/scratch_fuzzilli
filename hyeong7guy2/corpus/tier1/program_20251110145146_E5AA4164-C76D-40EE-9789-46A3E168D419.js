function F1() {
    if (!new.target) { throw 'must be called with new'; }
    this.a = 2147483647;
}
const v3 = new F1();
new F1();
new F1();
new Uint16Array();
const v8 = class {
}
v3.a &&= 2147483647;
new BigUint64Array();
new v8();
const v12 = %WasmStruct();
[1000000.0,-2.2250738585072014e-308,0.375534158207499,-970.4007100619281,-429.0500180262087,-2.509394143569512,1.7976931348623157e+308,-7.502827277178513e+307,Infinity,-8.675970620904645];
[863866.8122047381,5.0,1000000.0,2.220446049250313e-16,-3.2853188981193225e+307,0.13986407329482142,NaN,-9.421996108961025];
class C18 {
}
const v19 = {};
function F20(a22, a23) {
    if (!new.target) { throw 'must be called with new'; }
    a23.prototype;
    const v25 = this.constructor;
    try { new v25(Symbol, Symbol); } catch (e) {}
}
new F20("a", C18);
const v28 = new F20("string", v19);
v28.g = v28;
