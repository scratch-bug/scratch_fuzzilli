const v3 = new Float64Array(1000);
const v4 = class extends WeakMap {
    static 3 = v3;
    static #valueOf(a6, a7, a8) {
    }
}
function f9(a10, a11) {
}
new Promise(f9);
const v14 = new v4();
gc({ execution: "async", type: "major" });
let {"a":v21,"b":v22,"c":v23,} = v14;
