for (let v1 = 0; v1 < 25; v1++) {
    Array["p" + v1] = v1;
}
try { Array.__proto__ = Array; } catch (e) {}
