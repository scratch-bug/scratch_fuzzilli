import cpp

/** Calls to ForceContextAllocation. */
class ForceCtxCall extends FunctionCall {
  ForceCtxCall() {
    exists(Function t |
      t = this.getTarget() and t.getName() = "ForceContextAllocation"
    )
  }
}

/** Calls to set_is_used. */
class SetIsUsedCall extends FunctionCall {
  SetIsUsedCall() {
    exists(Function t |
      t = this.getTarget() and t.getName() = "set_is_used"
    )
  }
}

/** Source-order precedence heuristic (no CFG):
 *  return true iff `a` appears earlier than `b` in the same file. */
predicate strictlyPrecedes(Stmt a, Stmt b) {
  a.getFile() = b.getFile() and
  a.getLocation().getStartLine() < b.getLocation().getStartLine()
}

from Function f, ForceCtxCall fc, Stmt sFC
where
  fc.getEnclosingFunction() = f and
  sFC = fc.getEnclosingStmt() and
  // Report ForceContextAllocation if there is no earlier set_is_used()
  // in the same function (based on source-line ordering).
  not exists(SetIsUsedCall su, Stmt sSU |
    su.getEnclosingFunction() = f and
    sSU = su.getEnclosingStmt() and
    strictlyPrecedes(sSU, sFC)
  )
select fc.getFile().getRelativePath(), fc.getLocation().getStartLine()
