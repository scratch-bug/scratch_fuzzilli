const v3 = new WeakMap();
class C4 {
    static p(a6, a7) {
        function* f8(a9, a10, a11) {
            yield* [a10,a7,"-9223372036854775808",Uint16Array,v3];
            return a7;
        }
        let v13;
        try { v13 = f8(WeakMap, a6, a7); } catch (e) {}
        return v13;
    }
}
new C4();
let v16 = [1711267668,-6,-268435456,-15];
const v17 = [-3.0,-0.0,-9.793455882282e+307];
try { v17(v16); } catch (e) {}
let v19 = 0;
do {
    v16 ||= v17;
    if (39295 >= v17) {
    } else {
    }
    v19++;
} while (v19 < 8)
