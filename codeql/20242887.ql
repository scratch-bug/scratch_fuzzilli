/** CVE-2024-2887-style pattern:
 *  - expression is either byte_length - byte_offset or UintPtrSub(byte_length, byte_offset), and
 *  - there is no guard that enforces an ordering relationship between byte_offset and byte_length.
 */
import cpp
import semmle.code.cpp.exprs.ComparisonOperation  // LEExpr / LTExpr / GEExpr / GTExpr

/** Compare two expressions as "effectively the same value" (ignoring simple implicit casts). */
predicate exprEq(Expr a, Expr b) {
  a = b or
  a.getUnconverted() = b.getUnconverted()
}

/** Candidate for a length value: variable name contains len/length, optionally with byte_ prefix. */
predicate isLikelyLengthExpr(Expr e) {
  exists(VariableAccess va |
    va = e and
    va.getTarget().getName().regexpMatch("(?i)(byte_)?(len|length)")
  )
}

/** Candidate for an offset value: variable name contains off/offset, optionally with byte_ prefix. */
predicate isLikelyOffsetExpr(Expr e) {
  exists(VariableAccess va |
    va = e and
    va.getTarget().getName().regexpMatch("(?i)(byte_)?(off|offset)")
  )
}

/**
 * Model length - offset / UintPtrSub(length, offset) patterns.
 *   - s      : the full subtraction expression
 *   - length : the length expression
 *   - offset : the offset expression
 */
predicate isLengthOffsetSubtraction(Expr s, Expr length, Expr offset) {
  // Pattern 1: length - offset
  exists(SubExpr sub |
    s = sub and
    sub.getLeftOperand()  = length and
    sub.getRightOperand() = offset and
    length  instanceof VariableAccess and
    offset  instanceof VariableAccess and
    length.(VariableAccess).getTarget() instanceof Variable and
    offset.(VariableAccess).getTarget() instanceof Variable and
    // Must not be the same variable
    length.(VariableAccess).getTarget() != offset.(VariableAccess).getTarget() and
    // Apply name-based heuristics
    isLikelyLengthExpr(length) and
    isLikelyOffsetExpr(offset)
  )
  or
  // Pattern 2: UintPtrSub(length, offset)
  exists(FunctionCall fc |
    s = fc and
    fc.getTarget().getName() = "UintPtrSub" and
    length = fc.getArgument(0) and
    offset = fc.getArgument(1) and
    isLikelyLengthExpr(length) and
    isLikelyOffsetExpr(offset)
  )
}

/**
 * Treat a comparison that involves both offset and length as an ordering guard.
 * We accept any relational operator (<=, >=, <, >) and do not insist on direction.
 */
predicate isOffsetLengthRelGuard(Expr offset, Expr length, Expr cond) {
  exists(LEExpr le |
    le = cond and
    (
      exprEq(le.getLeftOperand(),  offset) and exprEq(le.getRightOperand(), length) or
      exprEq(le.getLeftOperand(),  length) and exprEq(le.getRightOperand(), offset)
    )
  )
  or exists(LTExpr lt |
    lt = cond and
    (
      exprEq(lt.getLeftOperand(),  offset) and exprEq(lt.getRightOperand(), length) or
      exprEq(lt.getLeftOperand(),  length) and exprEq(lt.getRightOperand(), offset)
    )
  )
  or exists(GEExpr ge |
    ge = cond and
    (
      exprEq(ge.getLeftOperand(),  offset) and exprEq(ge.getRightOperand(), length) or
      exprEq(ge.getLeftOperand(),  length) and exprEq(ge.getRightOperand(), offset)
    )
  )
  or exists(GTExpr gt |
    gt = cond and
    (
      exprEq(gt.getLeftOperand(),  offset) and exprEq(gt.getRightOperand(), length) or
      exprEq(gt.getLeftOperand(),  length) and exprEq(gt.getRightOperand(), offset)
    )
  )
}

/** Treat UintPtrLessThanOrEqual(offset, length) as an ordering guard as well. */
predicate isOffsetLengthCallGuard(Expr offset, Expr length, FunctionCall fc) {
  fc.getTarget().getName() = "UintPtrLessThanOrEqual" and
  exprEq(fc.getArgument(0), offset) and
  exprEq(fc.getArgument(1), length)
}

/**
 * Determine whether there is any ordering guard for this subtraction site
 * earlier in the same function.
 *   - s      : length - offset / UintPtrSub(...) expression
 *   - length : length expression
 *   - offset : offset expression
 */
predicate hasOrderingGuard(Expr s, Expr length, Expr offset) {
  exists(IfStmt ifs |
    ifs.getEnclosingFunction() = s.getEnclosingFunction() and
    ifs.getLocation().getStartLine() < s.getLocation().getStartLine() and
    isOffsetLengthRelGuard(offset, length, ifs.getCondition())
  )
  or
  exists(FunctionCall fc |
    fc.getEnclosingFunction() = s.getEnclosingFunction() and
    fc.getLocation().getStartLine() < s.getLocation().getStartLine() and
    isOffsetLengthCallGuard(offset, length, fc)
  )
}

/**
 * Final query:
 *  - Find byte_length - byte_offset / UintPtrSub(byte_length, byte_offset) patterns
 *  - For which there is no earlier guard that compares offset and length.
 */
from Expr s, Expr length, Expr offset
where
  isLengthOffsetSubtraction(s, length, offset) and
  not hasOrderingGuard(s, length, offset)
select s.getFile().getRelativePath(), s.getLocation().getStartLine()