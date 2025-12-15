/**
 * Heuristic:
 * Find places using `function->context()` without any `IsNativeContext(...)` guard
 */
import cpp

from Function f, Expr ctxExpr
where
  ctxExpr.getEnclosingFunction() = f and
  ctxExpr.toString().matches("%->context%") and
  not exists(Call guard |
    guard.getEnclosingFunction() = f and
    guard.toString().matches("%IsNativeContext%")
  )
select
  ctxExpr.getFile().getRelativePath(), ctxExpr.getLocation().getStartLine()
