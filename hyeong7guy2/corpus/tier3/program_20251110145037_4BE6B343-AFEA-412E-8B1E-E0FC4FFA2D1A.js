const v3 = {
    [Symbol]() {
    },
};
function F4() {
    if (!new.target) { throw 'must be called with new'; }
    this.f = v3;
}
class C6 extends F4 {
}
new C6();
const v8 = new C6();
const v9 = [F4,C6,C6,F4,v8];
function f10() {
    return v9;
}
const v11 = %WasmStruct();
gc({ execution: "async", type: "minor" });
