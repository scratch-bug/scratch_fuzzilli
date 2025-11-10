function F0() {
    if (!new.target) { throw 'must be called with new'; }
    this.a = 1073741825;
}
const v3 = new F0();
const v5 = { __proto__: v3 };
Date["parse"]("parse");
