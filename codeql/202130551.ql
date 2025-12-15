import cpp

class V8TargetFn extends Function {
  V8TargetFn() {
    this.getQualifiedName().matches("%::SetPropertyInternal%") or
    this.getQualifiedName().matches("%::SetProperty%") or
    this.getQualifiedName().matches("%::DefineOwnProperty%")
  }
}

predicate isSetSuperProperty(Call c) {
  exists(Function cal |
    c.getTarget() = cal and
    cal.getQualifiedName().matches("%Object::SetSuperProperty%")
  )
}

predicate isLocalStore(Call c) {
  exists(Function cal |
    c.getTarget() = cal and
    (
      cal.getQualifiedName().matches("%::AddDataProperty%") or
      cal.getQualifiedName().matches("%::AddDataPropertyInternal%") or
      cal.getQualifiedName().matches("%::CreateDataProperty%") or
      cal.getQualifiedName().matches("%::DefineOwnProperty%") or
      cal.getQualifiedName().matches("%::SetOwnProperty%")
    )
  )
}

predicate isNothingCall(Call c) {
  exists(Function cal |
    c.getTarget() = cal and
    cal.getQualifiedName().regexpMatch("\\bNothing\\b")
  )
}

predicate isGetPropertyLike(Call c) {
  exists(Function cal |
    c.getTarget() = cal and
    cal.getQualifiedName().regexpMatch("Get.*Property")
  )
}

from V8TargetFn f, IfStmt br, Stmt block
where
  br.getEnclosingFunction() = f and
  (block = br.getThen() or block = br.getElse()) and
  block.getLocation().getStartLine() >= 0 and
  block.getLocation().getEndLine()   >= block.getLocation().getStartLine() and

  exists(Call gp |
    gp.getEnclosingFunction() = f and
    isGetPropertyLike(gp) and
    gp.getLocation().getStartLine() >= block.getLocation().getStartLine() and
    gp.getLocation().getEndLine()   <= block.getLocation().getEndLine()
  ) and

  (
    exists(Call storeCall |
      storeCall.getEnclosingFunction() = f and
      isLocalStore(storeCall) and
      storeCall.getLocation().getStartLine() >= block.getLocation().getStartLine() and
      storeCall.getLocation().getEndLine()   <= block.getLocation().getEndLine()
    )
    or
    exists(Call nothingC |
      nothingC.getEnclosingFunction() = f and
      isNothingCall(nothingC) and
      nothingC.getLocation().getStartLine() >= block.getLocation().getStartLine() and
      nothingC.getLocation().getEndLine()   <= block.getLocation().getEndLine()
    )
    or
    exists(ReturnStmt r |
      r.getEnclosingFunction() = f and
      r.getLocation().getStartLine() >= block.getLocation().getStartLine() and
      r.getLocation().getEndLine()   <= block.getLocation().getEndLine()
    )
  ) and

  not exists(Call ssp |
    ssp.getEnclosingFunction() = f and
    isSetSuperProperty(ssp) and
    ssp.getLocation().getStartLine() >= block.getLocation().getStartLine() and
    ssp.getLocation().getEndLine()   <= block.getLocation().getEndLine()
  )

select block.getFile().getRelativePath(), block.getLocation().getStartLine()