/**
 * A: Find direct calls to InstructionAccurateScope with <=1 arg,
 * or with a non-literal 2nd arg (no explicit numeric reserve).
 */
import cpp

from Call c, Function f
where
  c.getTarget() = f and
  f.getName() = "InstructionAccurateScope" and
  (
    // no explicit reserve (only `this` or nothing)
    c.getNumberOfArguments() <= 1
    or
    // 2nd arg exists but is not a plain decimal literal (fallback: just isConstant)
    (
      c.getNumberOfArguments() >= 2 and
      not c.getArgument(1).isConstant()
    )
  )
select c.getFile().getRelativePath(), c.getLocation().getStartLine()
