function f0() {
    return f0;
}
const v3 = class {
}
const v5 = class extends v3.constructor {
}
try { f0(-36818, Date, v3, ...v5); } catch (e) {}
