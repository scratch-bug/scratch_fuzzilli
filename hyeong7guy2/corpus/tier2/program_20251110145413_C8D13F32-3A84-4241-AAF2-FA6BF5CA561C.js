const v2 = new Array(3312);
const v12 = {
    [Symbol]() {
        const v11 = {
            next() {
                return {};
            },
        };
    },
};
function f14() {
    return f14;
}
function f16() {
    void arguments;
    for (const v19 of v2) {
    }
    let v20 = 0;
    do {
        arguments.valueOf = f14;
        switch (f14) {
            case Symbol:
                break;
        }
        v20++;
    } while (v20 < 10)
    const v25 = Symbol.dispose;
    const v39 = {
        [v25](a27, a28, a29) {
            try {
                a28 * 3312;
                const v31 = (a32, a33, a34) => {
                };
                const v35 = {};
                super.o(v25, a29, f14);
            } catch(e38) {
            }
        },
    };
    using v40 = v39;
    return v40;
}
f16();
function F43(a45, a46, a47, a48) {
    if (!new.target) { throw 'must be called with new'; }
    this.e = -888.3041226099666;
    this.b = a48;
}
new F43(2072588213, 536870888, 3312, 3312);
new F43(3312, 2072588213, 3312, 536870888);
new F43(536870888, 3312, 2072588213, 536870888);
new F43(2072588213, 536870888, 536870888, 3312);
async function f53(a54, a55) {
    try { a54(); } catch (e) {}
    const v58 = Symbol();
    const v59 = Symbol.asyncDispose;
    const v68 = {
        [v59](a61, a62) {
            for (let v63 = 0; v63 < 100; v63++) {
            }
            const v66 = ArrayBuffer.prototype.resize;
            try { v66.call(v58); } catch (e) {}
        },
    };
}
f53(f53);
