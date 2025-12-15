import cpp

// Detect cases where BuildStoreReceiverMap is called with a map derived from new_target
// (via BuildAllocateFastObject), but lacks a constructor guard (CheckConstructor).
predicate missingConstructorGuardInStoreReceiverMap(FunctionCall fc) {
  exists(Function f |
    fc.getTarget() = f and
    f.getName() = "BuildStoreReceiverMap" and
    exists(Expr map |
      map = fc.getArgument(1) and
      exists(FunctionCall innerCall |
        innerCall.getTarget().getName() = "BuildAllocateFastObject" and
        innerCall.getArgument(1) = map and
        not exists(FunctionCall guard |
          guard.getTarget().getName() = "CheckConstructor" and
          guard.getArgument(0) = map // Considered missing if no constructor check exists
        )
      )
    )
  )
}

// Restrict analysis to files within the src directory only
from FunctionCall fc
where fc.getLocation().getFile().getRelativePath().regexpMatch("^src/") and missingConstructorGuardInStoreReceiverMap(fc)
select fc.getLocation().getFile(), fc.getLocation().getStartLine()