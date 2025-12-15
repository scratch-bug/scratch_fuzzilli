import cpp

/** Scan only functions that actually call NextDouble */
private predicate funcHasNextDouble(Function f) {
  exists(FunctionCall c |
    c.getEnclosingFunction() = f and
    c.getTarget().getName().regexpMatch("(^|.*::)NextDouble$")
  )
}

/** Detects half-ULP delta assignment patterns:
 *  e.g., double delta = 0.5 * (base::Double(value).NextDouble() - value);
 */
private predicate isHalfUlpAssign(Stmt s) {
  s.toString().regexpMatch(
    "double\\s+\\w+\\s*=\\s*0\\.5\\s*\\*[^;\\n]*\\bNextDouble\\s*\\("
  )
}

/** Detects zero-comparison statements such as:
 *   delta <= 0, delta < 0, delta == 0
 *  (Variable binding ignored for performance)
 */
private predicate isCmpVsZero(Stmt s) {
  s.toString().regexpMatch("(<=|<|==)\\s*0(?:\\.0+)?\\b")
}

/** Detects >= or <= comparisons, e.g.:
 *   fraction >= delta
 *  (Loose matching, variable name ignored)
 */
private predicate isGeComparison(Stmt s) {
  s.toString().regexpMatch("\\b>=\\s*\\w+\\b|\\b\\w+\\s*<=\\b\\w+")
}

/** Detects clamping patterns like:
 *   std::max(NextDouble(0.0), delta)
 */
private predicate isClampStdMax(Stmt s) {
  s.toString().regexpMatch("\\bstd::max\\s*\\(") and
  s.toString().regexpMatch("\\bNextDouble\\s*\\(\\s*0(?:\\.0+)?\\s*\\)")
}

/** Detects FTZ (Flush-To-Zero) guard checks:
 *   e.g., GetFlushDenormals(), FPU::GetFlushDenormals(), IsFlushDenormalsEnabled()
 */
private predicate isFlushGuard(Stmt s) {
  s.toString().regexpMatch("\\b(GetFlushDenormals|FPU::GetFlushDenormals|IsFlushDenormalsEnabled)\\s*\\(")
}

from Function f, Stmt assignS, Stmt outS, string kind
where
  funcHasNextDouble(f) and
  assignS.getEnclosingFunction() = f and
  isHalfUlpAssign(assignS) and
  (
    /* (1) Report the half-ULP assignment itself */
    outS = assignS and kind = "half-ulp assignment"

    or

    /* (2) After the assignment: detect comparisons with zero
     *     and ensure there is NO FTZ guard in between.
     */
    exists(Stmt cmp |
      cmp.getEnclosingFunction() = f and
      cmp.getLocation().getStartLine() > assignS.getLocation().getStartLine() and
      isCmpVsZero(cmp) and
      not exists(Stmt g |
        g.getEnclosingFunction() = f and
        g.getLocation().getStartLine() > assignS.getLocation().getStartLine() and
        g.getLocation().getStartLine() < cmp.getLocation().getStartLine() and
        isFlushGuard(g)
      )
    ) and outS = assignS and kind = "cmp vs 0 w/o flush guard"

    or

    /* (3) After the assignment: detect >= or <= comparisons,
     *     and ensure there is NO std::max(NextDouble(0.0), ...) clamp in between.
     */
    exists(Stmt ge |
      ge.getEnclosingFunction() = f and
      ge.getLocation().getStartLine() > assignS.getLocation().getStartLine() and
      isGeComparison(ge) and
      not exists(Stmt cl |
        cl.getEnclosingFunction() = f and
        cl.getLocation().getStartLine() > assignS.getLocation().getStartLine() and
        cl.getLocation().getStartLine() < ge.getLocation().getStartLine() and
        isClampStdMax(cl)
      )
    ) and outS = assignS and kind = "use in >= w/o clamp"
  )

select outS.getFile().getRelativePath(), outS.getLocation().getStartLine()
