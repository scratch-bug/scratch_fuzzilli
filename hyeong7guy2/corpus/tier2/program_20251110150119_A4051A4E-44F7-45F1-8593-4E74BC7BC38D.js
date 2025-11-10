class C3 {
}
function f4() {
    return "bigint";
}
delete C3?.d;
Object.defineProperty(C3, "h", { configurable: true, get: f4 });
