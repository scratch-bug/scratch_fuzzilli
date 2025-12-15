import cpp

/** Whether the expression has an unsigned integral type (including typedefs like size_t, uint32_t, etc.) */
predicate isUnsignedIntegralExpr(Expr e) {
  exists(IntegralType t |
    e.getType() = t and
    t.isUnsigned()
  )
}

/** Length-like variable names */
predicate isLengthLikeVar(Variable v) {
  v.getName().regexpMatch("(?i)(len|length|size|count|total)")
}

/** Offset-like variable names */
predicate isOffsetLikeVar(Variable v) {
  v.getName().regexpMatch("(?i)(off|offset|start|idx|index|pos)")
}

/** Returns true if expression e contains a reference to variable v (via VariableAccess). */
predicate exprUsesVar(Expr e, Variable v) {
  exists(VariableAccess va |
    va.getTarget() = v and
    va.getParent*() = e
  )
}

/**
 * Find unsigned subtraction expressions (SubExpr) that use both length-like and offset-like variables,
 * where the subtraction is *not* guarded by an if-statement that compares the same length/offset pair.
 *
 * In other words, we look for:
 *   - A subtraction whose result type is unsigned integral
 *   - The expression tree of the subtraction contains both a length-like variable and an offset-like variable
 *   - There is no enclosing if-statement whose condition uses both variables (acting as a range check/guard)
 */
from SubExpr sub, Variable lenVar, Variable offVar
where
  // Result type is an unsigned integral
  isUnsignedIntegralExpr(sub) and

  // The subtraction expression contains a length-like variable
  exists(VariableAccess vaLen |
    vaLen.getTarget() = lenVar and
    isLengthLikeVar(lenVar) and
    vaLen.getParent*() = sub
  ) and

  // The subtraction expression contains an offset-like variable
  exists(VariableAccess vaOff |
    vaOff.getTarget() = offVar and
    isOffsetLikeVar(offVar) and
    vaOff.getParent*() = sub
  ) and

  // And there is no if-guard that:
  //  - encloses this subtraction in its 'then' block, and
  //  - whose condition uses both the length and offset variables
  not exists(IfStmt s |
    // The subtraction is inside the 'then' branch of s
    sub.getParent*() = s.getThen() and
    // The condition of s references both the length and offset variables
    exprUsesVar(s.getCondition(), lenVar) and
    exprUsesVar(s.getCondition(), offVar)
  )
select sub.getFile().getRelativePath(), sub.getLocation().getStartLine()
