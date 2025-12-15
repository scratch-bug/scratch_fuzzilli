import cpp

/* is_stable() call within an if-condition */
cached predicate isStableCallInIf(IfStmt s, FunctionCall c) {
  c.getEnclosingStmt() = s and
  exists(Function callee |
    c.getTarget() = callee and callee.getName() = "is_stable"
  )
}

/* Ensure exactly one call exists in the condition (i.e., only is_stable) */
cached predicate onlyOneCallInCondAndItIsStable(IfStmt s) {
  exists(FunctionCall stab | isStableCallInIf(s, stab)) and
  1 = count(FunctionCall fc | fc.getEnclosingStmt() = s)
}

/* Ensure the condition has no logical/comparison/ternary tokens */
cached predicate condHasNoJunctionOrComparison(IfStmt s) {
  not s.getCondition().toString().regexpMatch(
    "\\|\\||\\&\\&|\\b(and|or)\\b|==|!=|<=|>=|<|>|\\?"
  )
}

/* Main: standalone is_stable()/!is_stable() condition + emit locations */
from IfStmt s, FunctionCall stab, Function f, Location ifLoc, Location callLoc
where
  s.getEnclosingFunction() = f and
  isStableCallInIf(s, stab) and
  onlyOneCallInCondAndItIsStable(s) and
  condHasNoJunctionOrComparison(s) and
  ifLoc = s.getLocation() and
  callLoc = stab.getLocation()
select stab.getFile().getRelativePath(), stab.getLocation().getStartLine()
