import cpp

// Find BuildAllocateFastObject calls missing a Map.constructor == target guard
predicate missingMapConstructorGuard(FunctionCall fc) {
  exists(Function f |
    fc.getTarget() = f and
    f.getName() = "BuildAllocateFastObject" and
    not exists(FunctionCall guard |
      guard.getTarget().getName() = "CheckConstructor" and
      guard.getArgument(0) = fc.getArgument(0) // No constructor check for new_target
    )
  )
}

// Restrict analysis to files within the src directory only
from FunctionCall fc
where fc.getLocation().getFile().getRelativePath().regexpMatch("^src/") and missingMapConstructorGuard(fc)
select fc.getLocation().getFile(), fc.getLocation().getStartLine()
