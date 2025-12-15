import cpp

from Function f, IfStmt ifA, IfStmt ifB, Expr condA, Expr condB, ReturnStmt rA, ReturnStmt rB
where
  f = ifA.getEnclosingFunction() and
  f = ifB.getEnclosingFunction() and

  condA.getEnclosingStmt() = ifA and
  condA.toString().matches("%literal_contains_escapes%") and

  rA.getEnclosingStmt() = ifA.getThen() and
  rA.getExpr().toString().matches("%Default%") and

  condB.getEnclosingStmt() = ifB and
  condB.toString().matches("%eval_string%") and

  rB.getEnclosingStmt() = ifB.getThen() and
  rB.getExpr().toString().matches("%Eval%") and

  ifA.getLocation().getFile() = ifB.getLocation().getFile() and
  ifA.getLocation().getStartLine() < ifB.getLocation().getStartLine()
select ifB.getFile().getRelativePath(), ifB.getLocation().getStartLine()
