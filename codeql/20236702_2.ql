/**
 * Heuristic detector for CVE-2023-6702-like patterns (uses toString() instead of getCode()).
 * - Avoids Call::getCode() missing error by using toString() on nodes.
 *
 * Note: This is still a heuristic (textual) detector. For higher precision, consider
 * using DataFlow config + AST-specific types when your CodeQL C++ pack supports them.
 */

import cpp

from Function fun, Expr ctxExpr, Call callExpr
where
  // Find any expression in the function whose textual form looks like "->context"
  ctxExpr.getEnclosingFunction() = fun and
  ctxExpr.toString().matches("%->context%") and

  // Find a Call in same function whose textual form looks like "->get("
  callExpr.getEnclosingFunction() = fun and
  callExpr.toString().matches("%->get(%") and

  // Heuristic: ensure call text contains the same context text (receiver alias)
  callExpr.toString().matches("%" + ctxExpr.toString() + "%") and

  // No textual IsNativeContext/IsFunctionContext guard present that references the same ctx text
  not exists(Call g |
    g.getEnclosingFunction() = fun and
    g.toString().matches("%IsNativeContext%") and
    g.toString().matches("%" + ctxExpr.toString() + "%")
  )
select callExpr.getFile().getRelativePath(), callExpr.getLocation().getStartLine()
