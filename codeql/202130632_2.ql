import cpp

from IfStmt s, FunctionCall c, Function f, Function callee, Location ifLoc, Location callLoc
where
  s.getEnclosingFunction() = f and
  c.getEnclosingFunction() = f and
  c.getEnclosingStmt() = s and
  c.getTarget() = callee and
  (callee.getName() = "is_stable" or callee.getQualifiedName().regexpMatch("\\bis_stable\\b")) and
  ifLoc = s.getLocation() and
  callLoc = c.getLocation()
select c.getFile().getRelativePath(), c.getLocation().getStartLine()
