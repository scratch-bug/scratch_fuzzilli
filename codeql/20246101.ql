import cpp

/** Identify NextSpillOffset(...) calls */
class NextSpillOffsetCall extends FunctionCall {
  NextSpillOffsetCall() {
    this.getTarget().getName().regexpMatch("NextSpillOffset")
  }
}

/** Identify loops that iterate over VarState* */
class VarStateLoop extends ForStmt {
  VarStateLoop() {
    this.toString().regexpMatch("VarState")
  }
}

/** Identify expressions slot->offset() */
class SlotOffsetExpr extends Expr {
  SlotOffsetExpr() {
    this.toString().regexpMatch("\\->offset\\s*\\(")
  }
}

/** Identify "slot = *(slot + 1)" style shifting */
class SlotShiftExpr extends Expr {
  SlotShiftExpr() {
    this.toString().regexpMatch("\\*slot\\s*=\\s*\\*\\(slot\\s*\\+\\s*1\\)")
  }
}

from VarStateLoop loop, BreakStmt brk, 
     NextSpillOffsetCall spillCalc, 
     SlotOffsetExpr offsetExpr, SlotShiftExpr shiftExpr
where
  // All these constructs must appear within the same loop body
  brk.getParent*() = loop and
  spillCalc.getEnclosingStmt() = loop and
  offsetExpr.getEnclosingStmt() = loop and
  shiftExpr.getEnclosingStmt() = loop

  // Condition controlling the break should compare offset to a computed value
  and brk.getParent().toString().regexpMatch("slot->offset.*==")

select brk.getFile().getRelativePath(), brk.getLocation().getStartLine()