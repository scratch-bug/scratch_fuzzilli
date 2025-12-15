import cpp

predicate isHasBytecode(Call c) {
  c.getTarget().getName().regexpMatch("(?i)has_bytecode_array") or
  c.toString().regexpMatch("(?i)\\bhas_bytecode_array\\s*\\(")
}

predicate isHasFeedback(Call c) {
  c.getTarget().getName().regexpMatch("(?i)has_feedback_metadata") or
  c.toString().regexpMatch("(?i)\\bhas_feedback_metadata\\s*\\(")
}

predicate isSetFeedback(Call c) {
  c.getTarget().getName().regexpMatch("(?i)set_feedback_metadata") or
  c.toString().regexpMatch("(?i)\\bset_feedback_metadata\\s*\\(")
}

/** Returns true when statement s is textually (file/line) contained inside the then-block of IfStmt i */
predicate inThen(IfStmt i, Stmt s) {
  s.getLocation().getFile() = i.getThen().getLocation().getFile() and
  s.getLocation().getStartLine() >= i.getThen().getLocation().getStartLine() and
  s.getLocation().getEndLine()   <= i.getThen().getLocation().getEndLine()
}

from IfStmt ifs, Call hasB, Function fn
where
  // The condition contains a call to has_bytecode_array()
  hasB.getEnclosingStmt() = ifs and
  isHasBytecode(hasB) and

  fn = ifs.getEnclosingFunction() and

  // Inside the then-block, there exists a use that references feedback_metadata
  // (either member access like ->feedback_metadata or .feedback_metadata, or get_feedback_metadata())
  exists(Expr use |
    use.getEnclosingFunction() = fn and
    inThen(ifs, use.getEnclosingStmt()) and
    (
      use.toString().regexpMatch("(?i)(->|\\.)\\s*feedback_metadata\\b") or
      use.toString().regexpMatch("(?i)\\bget_feedback_metadata\\s*\\(")
    )
  ) and

  // There is NO has_feedback_metadata() guard inside the then-block
  not exists(Call guard |
    guard.getEnclosingFunction() = fn and
    inThen(ifs, guard.getEnclosingStmt()) and
    isHasFeedback(guard)
  ) and

  // There is no prior set_feedback_metadata(...) call before the if (in the same file)
  not exists(Call setF |
    setF.getEnclosingFunction() = fn and
    isSetFeedback(setF) and
    setF.getLocation().getEndLine() < ifs.getLocation().getStartLine() and
    setF.getLocation().getFile() = ifs.getLocation().getFile()
  )
select ifs.getFile().getRelativePath(), ifs.getLocation().getStartLine()
