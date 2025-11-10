const v1 = new Map();
function f2() {
    return v1;
}
const v3 = class {
}
new v3();
%PrepareFunctionForOptimization(f2);
%OptimizeFunctionOnNextCall(f2);
f2();
const v10 = { alphabet: "base64url", lastChunkHandling: "strict" };
const v12 = new Uint8Array(68);
v12.setFromBase64("-YEeQiH-NEKu03g=", v10);
