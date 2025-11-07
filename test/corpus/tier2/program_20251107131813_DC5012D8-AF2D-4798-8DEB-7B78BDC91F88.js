function callFun(a1) {
    a1();
}
var iterable = {};
const v5 = () => {
    const v6 = () => {
        return {};
    };
    const v8 = () => {
    };
    return { next: v6, return: v8 };
};
iterable[Symbol.iterator] = v5;
function* iterateAndThrow() {
    for (const v13 of iterable) {
        throw 42;
    }
}
const v15 = %PrepareFunctionForOptimization(iterateAndThrow);
try {
    const v16 = () => {
        return iterateAndThrow().next();
    };
    callFun(v16);
} catch(e20) {
}
iterateAndThrow();
const v22 = %OptimizeMaglevOnNextCall(iterateAndThrow);
try {
    iterateAndThrow().next();
} catch(e25) {
}
