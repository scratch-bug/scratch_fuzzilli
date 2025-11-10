const v1 = class {
    static [-2] = WeakSet;
}
const v2 = { __proto__: v1, e: WeakSet };
