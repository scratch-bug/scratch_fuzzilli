function F1() {
    if (!new.target) { throw 'must be called with new'; }
    this.a = 2147483647;
}
const v3 = new F1();
new F1();
new F1();
function f6() {
    return v3;
}
const v9 = new Uint16Array(869);
const v10 = class {
    [v9](a12, a13, a14) {
        class C15 extends F1 {
            static {
            }
            static #toString(a19, a20, a21) {
                return F1;
            }
        }
        new C15();
        return v3;
    }
}
new v10();
v3.a &&= 2147483647;
[] = v9;
new BigUint64Array(999);
new v10();
const v28 = %WasmStruct();
const v29 = f6();
let [] = [1000000.0,-2.2250738585072014e-308,0.375534158207499,-970.4007100619281,-429.0500180262087,-2.509394143569512,1.7976931348623157e+308,-7.502827277178513e+307,Infinity,-8.675970620904645];
v29.a |= 999;
[45296,1024,8,1486992685];
const v36 = new Float64Array(127);
v36[101];
([863866.8122047381,5.0,1000000.0,2.220446049250313e-16,-3.2853188981193225e+307,0.13986407329482142,NaN,-9.421996108961025])[4];
class C43 {
}
const v44 = {};
function F45(a47, a48) {
    if (!new.target) { throw 'must be called with new'; }
    a48.prototype;
    const v50 = this.constructor;
    v50.length;
    try { new v50(Symbol, Symbol); } catch (e) {}
    this.g = a48;
}
const v53 = new F45("a", C43);
try { v53.g(); } catch (e) {}
const v55 = new F45("string", v44);
v55.g = v55;
