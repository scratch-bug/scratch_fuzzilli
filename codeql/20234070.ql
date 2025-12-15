import cpp

/** calls like PopToRegister(...) or PopToReg(...) */
class PopCall extends FunctionCall {
  PopCall() {
    this.getTarget().getName().regexpMatch("PopToRegister|PopToReg|PopToGpRegister")
    and this.getFile().toString().regexpMatch("liftoff-compiler")
  }
}

/** calls that write into a register (LoadNullValue, Move, Store, LoadRoot, etc.) */
class OverwriteCall extends FunctionCall {
  OverwriteCall() {
    this.getTarget().getName().regexpMatch(
      "LoadNullValue|LoadNullValueForCompare|LoadRoot|Move|Store|Push|Set|Load"
    )
  }

  Expr getTargetReg() {
    result = this.getArgument(0)
  }
}

from PopCall pop, OverwriteCall ow
where
  // Same enclosing function (local pattern)
  pop.getEnclosingFunction() = ow.getEnclosingFunction()

  // The register obtained from PopToRegister is the same as overwritten register
  and pop.getArgument(0).toString() = ow.getTargetReg().toString()

  // Very broad but ensures real danger code paths
  and pop.toString().regexpMatch("extern|convert|externalize")

select ow.getFile().getRelativePath(), ow.getLocation().getStartLine()