import cpp

/**
 * Detect functions that call BuildAllocateFastObject()
 * but never call ClearCurrentRawAllocation() afterward.
 * (Heuristic for missing clear after folded allocation.)
 */

from Function fn, Stmt allocStmt
where
  allocStmt.getEnclosingFunction() = fn and
  allocStmt.toString().regexpMatch("BuildAllocateFastObject\\s*\\(") and
  not exists(Stmt clearStmt |
    clearStmt.getEnclosingFunction() = fn and
    clearStmt.toString().regexpMatch("ClearCurrentRawAllocation\\s*\\(") and
    clearStmt.getLocation().getStartLine() > allocStmt.getLocation().getStartLine()
  )
select allocStmt.getFile().getRelativePath(), allocStmt.getLocation().getStartLine()