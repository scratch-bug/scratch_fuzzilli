import cpp

// Detect cases where BuildAllocateFastObject is called after TryGetConstant(new_target),
// meaning new_target was treated as a constant before object allocation.
predicate tryGetConstantAfterNewTarget(FunctionCall fc) {
  exists(Function f |
    fc.getTarget() = f and
    f.getName() = "BuildAllocateFastObject" and
    exists(FunctionCall constantCall |
      constantCall.getTarget().getName() = "TryGetConstant" and
      constantCall.getArgument(0) = fc.getArgument(0) // new_target fixed by TryGetConstant
    )
  )
}

// Restrict analysis to files within the src directory only
from FunctionCall fc
where fc.getLocation().getFile().getRelativePath().regexpMatch("^src/") and tryGetConstantAfterNewTarget(fc)
select fc.getLocation().getFile(), fc.getLocation().getStartLine()
