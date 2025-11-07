function hot_function(a1) {
    let r = /test/g;
    function f5() {
        let slow_obj = { a: 1 };
        if (a1) {
            delete slow_obj.a;
        }
        return slow_obj;
    }
    Object.defineProperty(r, "data", { get: f5, configurable: true });
    try {
        new RegExp(r);
    } catch(e16) {
    }
}
for (let i18 = 0; i18 < 100; i18++) {
    hot_function(false);
}
hot_function(true);
