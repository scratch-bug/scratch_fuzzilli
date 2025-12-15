import cpp

class MovCall extends FunctionCall {
  MovCall() {
    this.getTarget().getName() = "movss" or
    this.getTarget().getName() = "movsd"
  }

  string instr() { result = this.getTarget().getName() }
}

class SizeCall extends FunctionCall {
  Expr sizeExpr;

  SizeCall() {
    exists(int i |
      i >= 0 and i < this.getNumberOfArguments() and
      sizeExpr = this.getArgument(i) and
      (
        sizeExpr.toString().regexpMatch("kDoubleSize") or
        sizeExpr.toString().regexpMatch("kFloatSize")
      )
    )
  }

  Expr getSizeExpr() { result = sizeExpr }
}

predicate sameBlock(FunctionCall a, FunctionCall b) {
  a.getBasicBlock() = b.getBasicBlock()
}

from MovCall m, SizeCall s
where
  sameBlock(m, s) and
  (
    m.instr() = "movss" and
    s.getSizeExpr().toString().regexpMatch("kDoubleSize")
    or
    m.instr() = "movsd" and
    s.getSizeExpr().toString().regexpMatch("kFloatSize")
  )
select m.getFile().getRelativePath(), m.getLocation().getStartLine()
