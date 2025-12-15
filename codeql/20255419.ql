/**
 * find-fixed-only-load-handling-cpp.ql
 *
 * C/C++ (CodeQL) version:
 * Finds `if` statements that guard fixed-offset loads (e.g. `if (!load.index().valid())`)
 * where the then-branch uses load.base / load.offset but there is no fallback handling
 * for the dynamic-index case (e.g. no call to MarkAllStoresAsObservable in the same function).
 *
 * Adjust function name patterns in isFallbackCall() if your tree uses different names.
 */

import cpp

/**
 * helper predicate: detect fallback conservative calls
 * Use several name patterns that we expect in V8 code.
 */
predicate isFallbackCall(FunctionCall c) {
  c.getTarget().getName().matches("%MarkAllStoresAsObservable%") or
  c.getTarget().getName().matches("%ProtectAllStores%") or
  c.getTarget().getName().matches("%MarkAllStores%") or
  c.getTarget().getName().matches("%MarkAllStoresAsObservable%") // duplicate safe
}

/**
 * main query
 */
from IfStmt ifs, Function fn
where
  // If is inside a function
  ifs.getEnclosingFunction() = fn and

  // Condition contains "index().valid" (heuristic text match)
  ifs.getCondition().toString().matches("%index().valid()%") and

  // Condition appears to be the negated/fixed-offset branch (e.g., "!load.index().valid()")
  (
    ifs.getCondition().toString().matches("%!%index().valid()%")
    or ifs.getCondition().toString().matches("%index().valid()%==%false%")
    or ifs.getCondition().toString().matches("%==%false%index().valid()%")
  ) and

  // Then-branch exists and uses load.base / load.offset (text heuristic)
  exists(Stmt s |
    s = ifs.getThen() and
    (
      s.toString().matches("%load.base%")
      or s.toString().matches("%load.offset%")
      or s.toString().matches("%load.base()%")
      or s.toString().matches("%load.offset()%")
    )
  ) and

  // And there's NO fallback conservative handling in the same function
  not exists(FunctionCall fb | fb.getEnclosingFunction() = fn and isFallbackCall(fb))

select ifs.getFile().getRelativePath(), ifs.getLocation().getStartLine()