import cpp

// Whether a branch (then/else) mentions any Wasm↔JS wrapper or related tokens
private predicate branchMentionsWrapper(Stmt s) {
  s.toString().regexpMatch(
    "(?s)"
    // Wrapper family
    + "\\b(WasmToJSWrapper|WasmToJSWrapperAsm|WasmReturnPromiseOnSuspend|"
    + "WasmReturnPromiseOnSuspendAsm|WasmPromising|WasmPromisingWithSuspender|"
    + "JSToWasmWrapper|kWasmToJSWrapper)\\b"
    // Import references, casting, or dispatch tables
    + "|\\b(NewWasmApiFunctionRef|WasmApiFunctionRef::cast)\\b"
    + "|dispatch_table_for_imports\\s*\\(\\)\\s*\\->\\s*ref"
    // Call target setup traces
    + "|\\bset_call_target\\b"
  )
}

// True if either then or else branch of an if-statement mentions wrappers
private predicate hasWrapperMentionInBranch(IfStmt ifs) {
  exists(Stmt t | t = ifs.getThen() and branchMentionsWrapper(t))
  or
  exists(Stmt e | e = ifs.getElse() and branchMentionsWrapper(e))
}

// Whether the if-condition contains an "imported" guard
// (e.g., function.imported, !function.imported, IsImported(), is_imported(), imported(...))
private predicate conditionHasImportedGuard(IfStmt ifs) {
  exists(Expr cond |
    cond = ifs.getCondition() and
    cond.toString().regexpMatch(
      "function\\s*\\.\\s*imported"        // function.imported
      + "|!\\s*function\\s*\\.\\s*imported"// !function.imported
      + "|\\bIsImported\\b"                // IsImported
      + "|\\bis_imported\\b"               // is_imported
      + "|\\bimported\\s*\\("              // imported(...)
    )
  )
}

// Main query:
// Report if the branch mentions a Wasm/JS wrapper or import reference,
// but the if-condition lacks an 'imported' guard.
from IfStmt ifs
where
  hasWrapperMentionInBranch(ifs) and
  not conditionHasImportedGuard(ifs)
select
  ifs.getFile().getRelativePath(), ifs.getLocation().getStartLine()