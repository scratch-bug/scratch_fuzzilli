function F0() {
    if (!new.target) { throw 'must be called with new'; }
    this.h = 127;
    this.b = 127;
    this.f = 127;
}
new F0();
const v4 = new F0();
const v8 = new Int16Array();
function F10(a12, a13) {
    if (!new.target) { throw 'must be called with new'; }
    this.h = a12;
    this.a = 1651;
}
new F10(v8, v4);
class C15 {
    static valueOf(a17, a18) {
    }
    c = F10;
}
let v19 = 0;
do {
    function f20() {
        function f22(a23) {
            function f24() {
                return this;
            }
        }
        this.onmessage = f22;
        try {
            C15 ** C15;
        } finally {
            const v26 = {
                apply: f22,
                construct: f22,
                get: f22,
                isExtensible: f22,
                ownKeys: f22,
                set: f22,
                setPrototypeOf: f22,
            };
            new Proxy(C15, v26);
        }
    }
    [];
    new Worker(f20, { type: "function" });
    v19++;
} while (v19 < 7)
