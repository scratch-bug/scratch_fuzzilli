Symbol.toString = Symbol;
Symbol[Symbol.toPrimitive] = Symbol;
Symbol.iterator;
class C3 {
    static {
        function f5() {
            return f5;
        }
        function f6(a7) {
            return this;
        }
        Object.defineProperty(this, 1073741824, { get: f5, set: f6 });
    }
}
Symbol.toString = Symbol;
