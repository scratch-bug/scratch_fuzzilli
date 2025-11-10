function f0(a1, a2) {
    function f4(a5) {
        function f6(a7, a8, a9) {
            'use strict';
            return a1;
        }
        f6();
    }
    this.onmessage = f4;
}
new Worker(f0, { type: "function" });
