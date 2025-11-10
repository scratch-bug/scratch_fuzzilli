const v1 = Symbol.iterator;
const v10 = {
    [v1]() {
        let v3 = 10;
        const v9 = {
            next() {
                v3--;
                const v7 = v3 == 0;
                return { done: v7 };
            },
        };
        return v9;
    },
};
const v12 = Symbol.iterator;
const v18 = {
    [v12]() {
        const v17 = {
            next() {
                const v16 = {};
            },
        };
    },
};
class C19 {
    o(a21) {
    }
    static m(a23, a24) {
        return this;
    }
}
const v25 = new C19();
new Float64Array(512);
const v29 = class {
    static #toString(a31, a32, a33, a34) {
    }
    get f() {
    }
}
new v29();
for (const v37 of v10) {
    C19.f = v37;
}
switch (C19) {
    case v25:
        break;
}
