const v1 = class {
}
function F2(a4, a5) {
    if (!new.target) { throw 'must be called with new'; }
    this.d = a4;
}
new F2(v1);
new F2(9007199254740992);
