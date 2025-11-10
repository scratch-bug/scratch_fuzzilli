function F0() {
    if (!new.target) { throw 'must be called with new'; }
    [[this,this,this,this]];
}
try { (3n).pop(3n, 3n, F0, F0, F0); } catch (e) {}
