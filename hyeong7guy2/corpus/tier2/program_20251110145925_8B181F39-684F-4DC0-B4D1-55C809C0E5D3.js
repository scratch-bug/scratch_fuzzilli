function F0() {
    if (!new.target) { throw 'must be called with new'; }
}
const v3 = {
    get f() {
        return F0;
    },
    f: F0,
};
