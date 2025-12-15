/**
 * 2025-0291: find functions that trigger a loop re-visit by calling
 * AnalyzerIterator::MarkLoopForRevisitSkipHeader (or MarkLoopForRevisit).
 *
 * Usage: run this against a V8 CodeQL C/C++ database.
 */

import cpp

/**
 * A call expression whose resolved target's name contains one of the markers
 * we care about (MarkLoopForRevisitSkipHeader / MarkLoopForRevisit).
 */
predicate isMarkLoopRevisitCall(ExprCall c) {
  exists(Function target |
    // call target resolves to a function
    c.getTarget() = target and
    (
      target.getName().matches("%MarkLoopForRevisitSkipHeader%") or
      target.getName().matches("%MarkLoopForRevisit%")
    )
  )
}

/**
 * A function that (directly) contains such a call.
 * We report the enclosing function (could be a method or free function).
 */
from Function f
where exists(ExprCall c | c.getEnclosingFunction() = f and isMarkLoopRevisitCall(c))
select f.getFile().getRelativePath(), f.getLocation().getStartLine()