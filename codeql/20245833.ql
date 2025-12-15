/**
 * missing-is-uninhabited-ast-fixed.ql
 * Detect functions that contain an `if` condition referencing `kWasmBottom`
 * but have no calls to any `is_uninhabited`-like functions.
 *
 * Usage:
 *   codeql query run --database=<db> missing-is-uninhabited-ast-fixed.ql
 */
import cpp

/** Detects calls that look like is_uninhabited variants
 *  (case-insensitive, matches both name and qualified name). */
predicate looksLikeIsUninhabited(Call c) {
  exists(Function cal |
    cal = c.getTarget() and
    (
      cal.getName().regexpMatch("(?i).*is[_]*uninhabited.*") or
      cal.getQualifiedName().regexpMatch("(?i).*is[_]*uninhabited.*")
    )
  )
}

/** True if the function contains an `if` statement
 *  whose condition mentions `kWasmBottom`. */
predicate functionHasWasmBottomIf(Function f) {
  exists(IfStmt ifs |
    ifs.getEnclosingFunction() = f and
    ifs.getCondition().toString().matches("%kWasmBottom%")
  )
}

/** True if the function does NOT contain any calls
 *  to is_uninhabited-like functions. */
predicate functionMissesUninhabitedCall(Function f) {
  not exists(Call c |
    c.getEnclosingFunction() = f and looksLikeIsUninhabited(c)
  )
}

/** Main query:
 *  Find functions that reference `kWasmBottom` in conditions
 *  but lack any `is_uninhabited`-type call.
 *  These should likely be refactored to use property-based checks instead.
 */
from Function f
where functionHasWasmBottomIf(f) and functionMissesUninhabitedCall(f)
select f.getFile().getRelativePath(), f.getLocation().getStartLine()
