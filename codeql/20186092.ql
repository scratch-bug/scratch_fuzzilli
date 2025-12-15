import cpp

predicate isUnsignedIntegralExpr(Expr e) {
  exists(IntegralType t |
    e.getType() = t and
    t.isUnsigned()
  )
}

class UnsignedAddExpr extends AddExpr {
  UnsignedAddExpr() {
    isUnsignedIntegralExpr(this.getLeftOperand().getFullyConverted()) and
    isUnsignedIntegralExpr(this.getRightOperand().getFullyConverted())
  }
}

from BinaryOperation cmp, UnsignedAddExpr add, Expr limit
where
  (cmp.getOperator() = ">" or cmp.getOperator() = ">=") and

  (
    cmp.getLeftOperand() = add and
    limit = cmp.getRightOperand()
    or
    cmp.getRightOperand() = add and
    limit = cmp.getLeftOperand()
  ) and

  isUnsignedIntegralExpr(limit.getFullyConverted())
select cmp.getFile().getRelativePath(), cmp.getLocation().getStartLine()