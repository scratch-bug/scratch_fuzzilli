import cpp

class NarrowCast extends Expr {
  NarrowCast() {
    // Match any cast-like expression whose text mentions uint8_t/unsigned char
    this.toString().regexpMatch("uint8_t|unsigned char")
  }

  Expr original() { result = this.getAChild*() }
}

/** memory index variable candidates */
class MemIndexVar extends Expr {
  MemIndexVar() {
    this.toString().regexpMatch("mem(_|)index|memory_index")
  }
}

/** cached index variables */
class CachedIndexVar extends Expr {
  CachedIndexVar() {
    this.toString().regexpMatch("cached.*index")
  }
}

from BinaryOperation cmp, NarrowCast nc, MemIndexVar mem, CachedIndexVar cached
where
  // Comparison uses == or !=
  (cmp.getOperator() = "==" or cmp.getOperator() = "!=") and

  // One side: narrowing cast of cached index
  cmp.getAnOperand() = nc and
  nc.original().toString() = cached.toString() and

  // Other side: normal memory index variable
  cmp.getAnOperand() = mem and mem != nc

select nc.getFile().getRelativePath(), nc.getLocation().getStartLine()