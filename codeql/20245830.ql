import cpp

/** Whether the statement is a DCHECK (or CHECK) expression. */
predicate isDcheck(Stmt s) {
  s.toString().regexpMatch("\\bDCHECK(_[A-Z]+)?\\s*\\(")
  or s.toString().regexpMatch("\\bCHECK\\s*\\(") // remove if not needed
}

/** Whether the statement is an assignment of the form 'map = Update(isolate, map)' (allowing whitespace/newlines). */
predicate isUpdateAssignToMap(Stmt s) {
  s.toString().regexpMatch("(?s)\\bmap\\s*=\\s*Update\\s*\\(")
}

/** Whether the statement is a function call containing 'map' as an argument (simple regex approximation). */
predicate isCallWithMapArg(Stmt s) {
  // Identifier (function name) + parentheses containing the token 'map'
  s.toString().regexpMatch("(?s)\\b[A-Za-z_][A-Za-z_0-9]*\\s*\\([^;]*\\bmap\\b[^;]*\\)")
}

/** Returns true if statement a appears before statement b in the same file (by start line). */
predicate strictlyPrecedes(Stmt a, Stmt b) {
  a.getFile() = b.getFile() and
  a.getLocation().getStartLine() < b.getLocation().getStartLine()
}

/** Main query:
 *  Finds functions where 'map = Update(isolate, map)' is immediately followed
 *  (ignoring intervening DCHECK/CHECK statements) by a function call that takes 'map' as an argument.
 */
from Function f, Stmt sUpdate, Stmt sCall
where
  sUpdate.getEnclosingFunction() = f and
  sCall.getEnclosingFunction() = f and
  isUpdateAssignToMap(sUpdate) and
  strictlyPrecedes(sUpdate, sCall) and
  isCallWithMapArg(sCall) and
  // There must be no non-DCHECK statements between sUpdate and sCall.
  not exists(Stmt mid |
    mid.getEnclosingFunction() = f and
    strictlyPrecedes(sUpdate, mid) and strictlyPrecedes(mid, sCall) and
    not isDcheck(mid)
  )
select sUpdate.getFile().getRelativePath(), sUpdate.getLocation().getStartLine()
