function F0() {
    if (!new.target) { throw 'must be called with new'; }
    this.h = -60993;
}
for (let i = 0; i < 10; i++) {
    Reflect.construct(F0, [Reflect,Reflect], Object);
}
const v8 = Intl.DateTimeFormat;
v8(v8);
