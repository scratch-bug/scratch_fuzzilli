import cpp

predicate inTurboFanCompiler(File f) {
  f.getRelativePath().regexpMatch(".*(^|/)src/compiler/.*")
}

predicate inEAContext(Function f) {
  f.getQualifiedName().regexpMatch("(?i)(EscapeAnalysis|Escape|Reducer|Reduce|Analyze|Visit)")
  or exists(File fi | fi = f.getFile() and fi.getRelativePath().regexpMatch(".*escape.*"))
}

predicate isGuardLikeCallee(Function callee) {
  callee.getQualifiedName().regexpMatch("(?i)(SetEscaped|MarkEscaped|SetVirtualObjectEscaped|AssumeSafe|AssumeNoEscape|NoEscape)")
  or callee.getName().regexpMatch("(?i)(SetEscaped|MarkEscaped|AssumeSafe|NoEscape)")
}

class FrameOrStateValuesCase extends SwitchCase {
  FrameOrStateValuesCase() {
    exists(Expr e |
      e = this.getExpr() and
      e.toString().regexpMatch("(^|\\W)IrOpcode::k(FrameState|StateValues)(\\W|$)")
    )
  }
}

predicate caseHasGuardCall(SwitchCase cs) {
  exists(Call c, Function cal |
    c.getEnclosingStmt*() = cs and c.getTarget() = cal and isGuardLikeCallee(cal)
  )
}

from FrameOrStateValuesCase cs, Function fn, File f
where
  f = cs.getFile() and inTurboFanCompiler(f) and
  fn = cs.getEnclosingFunction() and inEAContext(fn) and
  cs.terminatesInBreakStmt() and
  not caseHasGuardCall(cs)
select cs.getFile().getRelativePath(), cs.getLocation().getStartLine()
