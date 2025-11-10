function F0(a2, a3) {
    if (!new.target) { throw 'must be called with new'; }
    async function* f4(a5, a6) {
        return F0;
    }
    f4(F0, F0).return(f4);
}
const v9 = new F0();
const v10 = new F0(v9, v9);
new F0();
new F0(v10, F0);
