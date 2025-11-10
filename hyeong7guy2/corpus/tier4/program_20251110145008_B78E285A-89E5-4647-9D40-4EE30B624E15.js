const v1 = Symbol.iterator;
const v10 = {
    [v1]() {
        let v3 = 10;
        const v9 = {
            next() {
                v3--;
                const v7 = v3 == 0;
                return { done: v7, value: v3 };
            },
        };
        return v9;
    },
};
class C11 {
    set c(a13) {
        let [] = v10;
    }
    static [v10] = v10;
    get e() {
        return v10;
    }
}
const v15 = new C11();
[3,127,20940,41788,7,28947,2147483649,-3];
new Float64Array(6);
new Int8Array(4096);
const v27 = new BigUint64Array(170);
let v28;
try { v28 = v10.instantiateStreaming(-58945n, v27, v15); } catch (e) {}
[2.2250738585072014e-308,Infinity,-2.2250738585072014e-308,-407919.8568009961,-311.53691893815164,5.707441543923821,1e-15,-2.2250738585072014e-308,0.0,1e-15];
let v30;
try { v30 = v28(Int8Array, 0.42768592100529856, 0.42768592100529856); } catch (e) {}
try {
} catch(e31) {
} finally {
}
const v32 = class extends Int8Array {
    set b(a34) {
        let v35 = 0;
        do {
            v30 = 6;
            if (arguments >= v35) {
            } else {
            }
            v35++;
        } while (v35 < 7)
    }
}
new v32();
new v32();
