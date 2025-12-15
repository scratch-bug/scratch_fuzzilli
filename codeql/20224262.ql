/**
 * Detect V8 sloppy-eval scope state mismatches:
 *
 * Pattern:
 *   - Scope::Snapshot resets flags (calls_eval_, sloppy_eval_can_extend_vars_)
 *   - Snapshot destructor or Reparent() does NOT fully restore them
 *   - This can cause reparse (after GC) to produce different bytecode
 *   - Leading to feedback vector slot-type mismatch (CVE-2023-3079 style)
 */

import cpp

/** Methods that reset eval-related flags inside Scope::Snapshot */
class SnapshotReset extends FunctionCall {
  SnapshotReset() {
    this.getTarget().getName().regexpMatch(".*sloppy_eval_can_extend_vars_.*|.*calls_eval_.*")
    and this.toString().regexpMatch("= false")
    and this.getFile().toString().regexpMatch("scopes.cc")
  }

  Expr getScopeObj() { result = this.getArgument(0) }
}

/** Methods that attempt to restore eval flags */
class SnapshotRestore extends FunctionCall {
  SnapshotRestore() {
    this.toString().regexpMatch(
      "RecordEvalCall|RecordDeclarationScopeEvalCall|sloppy_eval_can_extend_vars_|calls_eval_"
    )
    and this.getFile().toString().regexpMatch("scopes.cc")
  }

  Expr getScopeObj() { result = this.getArgument(0) }
}

/** A place where the Snapshot is active (constructor → destructor region) */
class SnapshotActiveRegion extends Stmt {
  SnapshotActiveRegion() {
    this.toString().regexpMatch("Snapshot")
  }
}

from SnapshotReset reset, SnapshotActiveRegion region
where
  // reset happens inside the region
  reset.getEnclosingStmt().getParent*() = region and

  // BUT restore does NOT mention the same scope object inside the region
  not exists(SnapshotRestore restore |
    restore.getScopeObj().toString() = reset.getScopeObj().toString() and
    restore.getEnclosingStmt().getParent*() = region
  )

select reset.getFile().getRelativePath(), reset.getLocation().getStartLine()