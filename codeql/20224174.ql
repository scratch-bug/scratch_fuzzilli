import cpp

/** Matches any max-like capacity function (very broad) */
class MaxLike extends FunctionCall {
  MaxLike() {
    this.getTarget().getName().regexpMatch(".*(Max|IntPtrMax|UintPtrMax|Clamp).*")
  }
}

/** Matches any expression that textually contains a plus (A + B) */
class BinaryAddText extends Expr {
  BinaryAddText() {
    this.toString().regexpMatch("\\+")
  }
}

/** Matches any array-allocating / resizing function used in V8 */
class CapacityRelatedResize extends FunctionCall {
  CapacityRelatedResize() {
    this.getTarget().getName().regexpMatch(
      ".*(ExtractFixedArray|Allocate|Grow|EnsureCapacity|Reallocate|Resize|CopyFixedArray).*"
    )
  }
}

from MaxLike capCalc, BinaryAddText addExpr, CapacityRelatedResize alloc
where
  // One of the Max parameters must be an addition (index + X)
  (capCalc.getArgument(0) = addExpr or capCalc.getArgument(1) = addExpr) and

  // Broad: allocation appears in same file (NOT same function)
  capCalc.getFile() = alloc.getFile() and

  // Avoid trivial max calculations that aren’t capacity
  capCalc.toString().regexpMatch("cap|size|length|elements|Capacity|Len")

select capCalc.getFile().getRelativePath(), capCalc.getLocation().getStartLine()