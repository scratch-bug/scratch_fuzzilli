import cpp

/* Detect calls to is_stable: match the target symbol name first,
   and fall back to a textual regex if the call target cannot be resolved. */
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

/* Decide whether function f contains at least one is_stable() call. */
predicate functionHasIsStable(Function f) {
  exists(FunctionCall c |
    c.getEnclosingFunction() = f and
    isStableCall(c)
  )
}

from Function f
where functionHasIsStable(f)
select f.getFile().getRelativePath(), f.getLocation().getStartLine()
