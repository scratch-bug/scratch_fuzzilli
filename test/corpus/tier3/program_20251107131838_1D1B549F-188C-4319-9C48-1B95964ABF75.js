function hot_function(a1, a2) {
    a1.push(a2.p);
}
function TypeA() {
    this.val = 1.1;
}
function TypeB() {
    this.val = {};
}
const v13 = {
    get p() {
        const v12 = new TypeA();
        return v12;
    },
};
const warm_provider = v13;
for (let i16 = 0; i16 < 100; i16++) {
    const v22 = new TypeA();
    let a = [v22];
}
const trigger_array = [TypeA()];
const v31 = {
    get p() {
        const v29 = new TypeB();
        trigger_array[0] = v29;
        const v30 = new TypeA();
        return v30;
    },
};
hot_function(trigger_array, v31);
