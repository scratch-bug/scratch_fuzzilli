/**
 * @name Early return on nullptr check
 * @description Finds patterns like: if (x == nullptr) return ...; (or { return ...; } only)
 * @kind problem
 * @id cpp/early-return-on-nullptr-check
 */

import cpp
import semmle.code.cpp.exprs.ComparisonOperation
import semmle.code.cpp.controlflow.Nullness

predicate isIntegerZeroLiteral(Expr e) {
  exists(Literal l, IntegralType t |
    l = e.getUnconverted() and
    e.getType() = t and
    l.getValue().regexpMatch("^0([uUlL]*)$")
  )
}

predicate isNullLike(Expr e) {
  e instanceof NullValue and
  not isIntegerZeroLiteral(e)
}

predicate isNullEqCheck(IfStmt ifs, Expr checked) {
  exists(EQExpr eq |
    ifs.getCondition() = eq and
    (
      checked = eq.getLeftOperand()  and isNullLike(eq.getRightOperand()) or
      checked = eq.getRightOperand() and isNullLike(eq.getLeftOperand())
    )
  )
}

predicate thenIsOnlyReturn(IfStmt ifs, ReturnStmt rs) {
  rs = ifs.getThen().(ReturnStmt)
  or
  (
    ifs.getThen().hasChild(rs, 0) and
    not ifs.getThen().hasChild(_, 1)
  )
}

from IfStmt ifs, Expr checked, ReturnStmt rs
where
  isNullEqCheck(ifs, checked) and
  thenIsOnlyReturn(ifs, rs)
select ifs.getFile().getRelativePath(), ifs.getLocation().getStartLine()
