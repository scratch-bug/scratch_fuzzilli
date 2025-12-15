import cpp

predicate hasIsWasmModuleObjectCheck(Expr cond) {
  exists(FunctionCall fc |
    fc.getTarget().getName() = "IsWasmModuleObject" and
    cond.getAChild*() = fc
  )
}

predicate inThenBranch(IfStmt ifs, Stmt s) {
  s.getParent*() = ifs.getThen()
}

class ResolveCall extends FunctionCall {
  ResolveCall() {
    this.getTarget().getName() = "Resolve" and
    (
      this.toString().regexpMatch(".*\\bresolver\\b\\s*(->|\\.)\\s*Resolve\\s*\\(.*") or
      this.toString().regexpMatch(".*Promise::Resolver.*Resolve\\s*\\(.*")
    )
  }
}

from IfStmt ifs, ResolveCall rc
where
  hasIsWasmModuleObjectCheck(ifs.getCondition()) and
  inThenBranch(ifs, rc.getEnclosingStmt())
select rc.getFile().getRelativePath(), rc.getLocation().getStartLine()