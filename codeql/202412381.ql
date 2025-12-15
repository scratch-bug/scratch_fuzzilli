import cpp

/**
Find calls to CanonicalEquality::EqualValueType (or similarly named EqualValueType)
that do not have an obvious heap_representation() textual check earlier in the same function.
*/

predicate isCanonicalEqualCall(Call c) {
  exists(Function cal |
    cal = c.getTarget() and
    (
      cal.getQualifiedName().regexpMatch("(?i).*::CanonicalEquality::EqualValueType$") or
      cal.getName().regexpMatch("(?i)^EqualValueType$") or
      c.toString().regexpMatch("(?i)\\bEqualValueType\\b")
    )
  )
}

predicate hasHeapRepTextInFunctionBefore(Call eqCall) {
  exists(Expr e |
    e.getEnclosingFunction() = eqCall.getEnclosingFunction() and
    e.toString().regexpMatch("(?i)heap_representation\\s*\\(") and
    e.getLocation().getStartLine() < eqCall.getLocation().getStartLine()
  )
}

from Call eqCall
where isCanonicalEqualCall(eqCall) and not hasHeapRepTextInFunctionBefore(eqCall)
select eqCall.getFile().getRelativePath(), eqCall.getLocation().getStartLine()
