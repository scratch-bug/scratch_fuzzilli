class C4 {
    static #p(a6, a7, a8, a9) {
        return a7;
    }
}
function f10(a11, a12) {
    function f14(a15) {
        const v17 = Symbol.iterator;
        const v25 = {
            [v17]() {
                let v19 = 10;
                const v24 = {
                    next() {
                        v19--;
                        v19 == 0;
                        return undefined;
                    },
                };
            },
        };
    }
    this.onmessage = f14;
    const v26 = %WasmStruct();
    0 instanceof C4;
    function F28(a30, a31, a32) {
        if (!new.target) { throw 'must be called with new'; }
    }
    F28();
    return a11;
}
const v36 = ["p","function"];
new Worker(f10, { arguments: v36, type: "function" });
