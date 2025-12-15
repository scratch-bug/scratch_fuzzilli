import cpp

/**
 * Detect calls to is_stable: match the target symbol first, fall back to text match if resolution fails
 * The result is one row per Function, and we also output the call Location.
 */

cached predicate isStableCall(FunctionCall c) {
  exists(Function callee |
    c.getTarget() = callee and
    (callee.getName() = "is_stable" or callee.getQualifiedName().regexpMatch("\\bis_stable\\b"))
  )
  or
  (
    not exists(Function callee | c.getTarget() = callee) and
    c.toString().regexpMatch("\\bis_stable\\s*\\(")
  )
}

/*
 Strategy:
  - Group by Function f
  - Check whether there exists a FunctionCall c inside f that satisfies isStableCall
  - If present, output that function and the Location (the first found call location) as the result
*/
predicate before(Location a, Location b) {
  a.getStartLine() < b.getStartLine() or
  a.getStartLine() = b.getStartLine() and a.getStartColumn() < b.getStartColumn()
}

from Function f, FunctionCall c, Location loc
where
  /* (optional) to restrict to compiler directories, remove the comment on the following and use it */
  /* and inCompilerFile(f) */
  c.getEnclosingFunction() = f and
  isStableCall(c) and
  c.getLocation() = loc and
  // pick the first is_stable() call within the function
  not exists(FunctionCall d |
    d.getEnclosingFunction() = f and
    isStableCall(d) and
    before(d.getLocation(), c.getLocation())
  )
select
  c.getFile().getRelativePath(),
  c.getLocation().getStartLine()

