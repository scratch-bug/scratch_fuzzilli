const v2 = new Date();
const v3 = /zabc|def/mvg;
function F4(a6) {
    if (!new.target) { throw 'must be called with new'; }
    this.d = 1.530066046415995e+308;
    this.c = 1.530066046415995e+308;
    this.b = a6;
}
const v7 = new F4(1.530066046415995e+308);
function F8(a10, a11, a12) {
    if (!new.target) { throw 'must be called with new'; }
    this.h = v3;
    this.f = Date;
}
new F8(F8, v2, v2);
new F8(v2, v7, 1.530066046415995e+308);
function F15(a17, a18) {
    if (!new.target) { throw 'must be called with new'; }
    this.a = 1.530066046415995e+308;
    this.b = a17;
    this.f = a18;
}
new F15(Date, F4);
const v20 = new F15(F15, F15);
const v21 = new F15(F15, F4);
const v22 = new F15(F8, v21);
v20 >> 1.530066046415995e+308;
const v24 = `
    function f25() {
        function f27(a28) {
            for (const v29 of a28) {
                for (let v30 = 0; v30 < 100; v30++) {
                    Date(1.530066046415995e+308);
                }
            }
        }
        this.onmessage = f27;
        if (v22 == v20) {
        } else {
        }
    }
    const v35 = [];
    new Worker(f25, { arguments: v35, type: "function" });
`;
eval(v24);
