import cpp

/** Include only calls whose targets are resolved functions */
class ResolvedCall extends Call {
  ResolvedCall() { exists(Function t | t = this.getTarget()) }
  Function tgt() { result = this.getTarget() }
}

/** Stack→Stack call candidate: matches functions whose name or qualified name fits stack-move patterns */
predicate isStackToStackCall(ResolvedCall c) {
  exists(string n |
    (n = c.tgt().getName() or n = c.tgt().getQualifiedName()) and
    n.regexpMatch("(?i)(stacktostack|stack.*to.*stack|emit.*stack.*stack.*move|spill.*stack|copy.*stack.*stack)")
  )
}

/** Stack→Register call candidate: matches functions whose name or qualified name fits stack→register move patterns */
predicate isStackToRegisterCall(ResolvedCall c) {
  exists(string n |
    (n = c.tgt().getName() or n = c.tgt().getQualifiedName()) and
    n.regexpMatch("(?i)(stacktoreg(ister)?|load.*stack.*reg(ister)?|emit.*stack.*reg(ister)?.*move|pop.*to.*reg(ister)?)")
  )
}

/** Loop detection */
predicate isLoop(Stmt s) { s instanceof ForStmt or s instanceof WhileStmt or s instanceof DoStmt }

/** Check if one statement is textually contained within another */
predicate within(Stmt inner, Stmt outer) {
  inner.getLocation().getStartLine() >= outer.getLocation().getStartLine() and
  inner.getLocation().getEndLine()   <= outer.getLocation().getEndLine()
}

/** 
 * Within the same function and same loop body, 
 * find cases where a Stack→Stack move call occurs before a Stack→Register move call.
 */
from ResolvedCall s2s, ResolvedCall s2r, Function f, Stmt loopS, Stmt a, Stmt b
where
  isStackToStackCall(s2s) and
  isStackToRegisterCall(s2r) and
  s2s.getEnclosingFunction() = f and
  s2r.getEnclosingFunction() = f and
  a = s2s.getEnclosingStmt() and
  b = s2r.getEnclosingStmt() and
  isLoop(loopS) and
  within(a, loopS) and within(b, loopS) and
  a.getLocation().getStartLine() < b.getLocation().getStartLine()
select s2r.getFile().getRelativePath(), s2r.getLocation().getStartLine()
