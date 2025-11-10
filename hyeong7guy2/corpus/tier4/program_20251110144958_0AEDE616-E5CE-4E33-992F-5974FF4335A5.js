const v0 = /i[xyz]?/mvgi;
const v1 = class {
    static {
        function f3(a4) {
            const v8 = {
                [v0](a6, a7) {
                    return this;
                },
            };
        }
        f3();
        f3(v0);
        const v11 = f3();
        f3(v0);
        f3(f3());
        f3(v11);
        f3();
        f3(f3);
    }
}
const v18 = new v1();
const v19 = new v1();
function f20() {
}
new Set();
[1000.0];
for (let v25 = 0; v25 < 32; v25++) {
    v18["p" + v25] = v25;
}
const v28 = {};
const v29 = {};
v29.d = Set;
v29.g = v19;
const t33 = {};
t33.g = v19;
const v31 = {};
v31.d = Set;
v31.h = v1;
