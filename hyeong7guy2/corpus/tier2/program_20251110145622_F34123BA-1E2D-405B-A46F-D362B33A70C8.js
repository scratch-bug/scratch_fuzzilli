function f0() {
    return f0;
}
const v3 = class {
    static [f0](a5, a6) {
    }
    static [f0];
}
function f7() {
    return f7;
}
try {
} finally {
}
%VerifyType(f7);
