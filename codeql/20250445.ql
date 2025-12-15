import cpp

/** Determines whether a function contains a jump-table related call 
 * such as AllocateJumpTable, EmitJumpTableIfExists, or EmitJumpTable.
 */
predicate hasJumpTableCall(Function f) {
  exists(FunctionCall fc |
    fc.getEnclosingFunction() = f and
    fc.toString().regexpMatch("AllocateJumpTable|EmitJumpTableIfExists|EmitJumpTable")
  )
}

/** Detects a local variable whose type indicates a HoleCheckElisionScope
 * or an optional wrapper around it.
 */
predicate isElider(LocalVariable v) {
  v.getType().toString().regexpMatch(
    "(^|.*\\b)(HoleCheckElisionScope|std::optional<.*HoleCheckElisionScope.*>|optional<.*HoleCheckElisionScope.*>)(\\b|.*$)"
  )
}

/** Identifies a boolean flag variable (e.g., first_jump_emitted). */
predicate isBoolFlag(LocalVariable v) {
  v.getType().toString().regexpMatch("\\bbool\\b")
}

/** Checks whether an if-statement’s condition references the boolean flag. */
predicate ifConditionReferencesFlag(IfStmt ifs, LocalVariable flag) {
  ifs.getCondition().toString().regexpMatch("\\b" + flag.getName() + "\\b")
}

/** Checks whether the body (then/else) of the if-statement 
 * contains a call like elider.emplace(...) or elider.reset(...).
 */
predicate ifBodyHasEliderCall(IfStmt ifs, LocalVariable elider) {
  exists(FunctionCall fc |
    fc.getEnclosingStmt*() = ifs and
    fc.toString().regexpMatch("\\b" + elider.getName() + "\\s*\\.\\s*(emplace|reset)\\s*\\(")
  )
}

/** Main query:
 * - The function must contain a jump-table call.
 * - The function must have a HoleCheckElisionScope-like variable (elider).
 * - A boolean flag variable is used as an if-condition.
 * - The if-statement body conditionally creates or resets the elider.
 */
from Function f, LocalVariable elider, LocalVariable flag, IfStmt ifs
where
  hasJumpTableCall(f) and
  elider.getFunction() = f and
  isElider(elider) and
  flag.getFunction() = f and
  isBoolFlag(flag) and
  ifs.getEnclosingFunction() = f and
  ifConditionReferencesFlag(ifs, flag) and
  ifBodyHasEliderCall(ifs, elider)
select elider.getFile().getRelativePath(), elider.getLocation().getStartLine()