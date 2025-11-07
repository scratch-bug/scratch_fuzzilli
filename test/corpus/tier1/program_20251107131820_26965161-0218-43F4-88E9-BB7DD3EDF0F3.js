var global_victim = { a: 1.1 };
function set_property(a4, a5) {
    a4.a = a5;
}
for (let i7 = 0; i7 < 20000; i7++) {
    set_property(global_victim, 2.2);
}
const v18 = {
    get p() {
        global_victim.b = {};
        return {};
    },
};
var provider = v18;
set_property(global_victim, provider.p);
