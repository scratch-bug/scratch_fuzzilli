function F3(a5, a6) {
    if (!new.target) { throw 'must be called with new'; }
    this.d = a5;
}
new F3();
new F3(-6, -8);
for (let v9 = 0; v9 < 43; v9++) {
    for (let i12 = 0, i13 = 10; i12 < i13; i12++, i13--) {
        let v21 = 0;
        do {
            const v23 = Symbol.iterator;
            const v26 = {
                [v23]() {
                    return {};
                },
            };
            v21++;
        } while (v21 < 5)
    }
}
