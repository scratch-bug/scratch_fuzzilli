function hot_func(a1) {
    var x = a1 + 1;
    const v7 = new Uint8ClampedArray(1);
    var arr = v7;
    arr[0] = x;
    if (arr[0] == 255) {
        var p = arr.p;
    }
}
for (let i15 = 0; i15 < 10000; i15++) {
    hot_func(1);
}
hot_func(2147483647);
