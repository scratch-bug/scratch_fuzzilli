import cpp

predicate conditionLooksLikeMapStore(Expr e) {
  e.toString().regexpMatch(
    "\\b(HeapObject::kMapOffset|kMapOffset)\\b"
    + "|" + "\\bstore\\s*\\.\\s*offset\\b"
    + "|" + "store\\s*\\.\\s*index\\s*\\(\\s*\\)\\s*\\.\\s*valid\\s*\\(\\s*\\)"
    + "|" + "store\\s*\\.\\s*index\\s*\\(\\s*\\)\\s*\\.\\s*valid\\b"
  )
}

predicate thenBranchHasPartialInvalidation(Stmt s) {
  exists(Stmt inner |
    inner = s.getAChild*() and
    inner.toString().regexpMatch("object_maps_\\s*\\.\\s*HasKeyFor\\s*\\(\\s*store\\s*\\.\\s*base\\s*\\(\\s*\\)\\s*\\)")
  )
  or
  exists(Stmt inner2 |
    inner2 = s.getAChild*() and
    inner2.toString().regexpMatch("object_maps_\\s*\\.\\s*Set\\s*\\([^\\)]*MapMaskAndOr")
  )
}

from IfStmt ifs, Expr cond, Function fn
where
  ifs.getEnclosingFunction() = fn and
  ifs.getCondition() = cond and
  conditionLooksLikeMapStore(cond) and
  thenBranchHasPartialInvalidation(ifs.getThen()) and
  not exists(ForStmt loop |
    loop.getEnclosingFunction() = fn and
    loop.toString().regexpMatch("for\\s*\\([^\\)]*object_maps_")
  )
select
  fn.getFile().getRelativePath(),
  ifs.getLocation().getStartLine()