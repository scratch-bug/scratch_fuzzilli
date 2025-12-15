/**
 * lead.wide.fixed.ql — Wider detection, robust parsing (V8 core filter applied)
 */
import cpp

/* ===== Toggle helpers ===== */
private predicate alwaysTrue()  { exists(int x | x = 0) }
private predicate alwaysFalse() { exists(int x | x = 0 and x = 1) }
predicate requireOpt() { alwaysFalse() }   // OPT precondition off (wide)
// predicate requireOpt() { alwaysTrue() } // OPT precondition on (OPT-only)

/* ===== V8 core file filter ===== */
private predicate isV8CoreFile(File f) {
  f.getRelativePath().regexpMatch("(^|.*/)(v8/)?src/.*") and
  not f.getRelativePath().regexpMatch("(^|.*/)(third_party|test|testing)/.*")
}

/* ===== Transition / Guard / Deopt ===== */
predicate isTransitionName(Function f) {
  f.getName().regexpMatch(
    "^(Transition(Elements|.*)|SetElementsKind|ElementsTransition|GetElementsTransitionMap"
    + "|Ensure.*Elements|Ensure.*ElementsKind|TryUpdate.*(Elements|Map)?|Migrate.*(Elements|Map)?).*"
  )
}

class TransitionCall extends FunctionCall {
  TransitionCall() {
    exists(Function fn | this.getTarget() = fn and isTransitionName(fn))
  }
}

predicate isGuardFunction(Function f) {
  f.getName().regexpMatch(
    "^(Check(Maps|Elements|ElementsKind|HeapObject|FieldType)"
    + "|Has(Fast|Double|Object)Elements"
    + "|Is(Fast|Holey|Double|Smi|SmiOrObject)Elements(Kind)?"
    + "|Verify.*Elements|Assert.*Elements|Validate.*Elements).*"
  )
}

predicate isDeoptFunction(Function f) {
  f.getName().regexpMatch("^(Deoptimize|DeoptimizeIf|BailoutIf|AbortIf).*")
}

/* ===== OPT precondition (optional) ===== */
predicate hasOptBeforeIntra(TransitionCall tc) {
  exists(FunctionCall c, Function f |
    c.getEnclosingFunction() = tc.getEnclosingFunction() and
    c.getTarget() = f and
    f.getName().regexpMatch("Optimize|Optimized|Optimization|Turbofan|CodeKind::OPTIMIZED_FUNCTION|kOptimized|is_optimized") and
    c.getLocation().getFile() = tc.getLocation().getFile() and
    c.getLocation().getStartLine() < tc.getLocation().getStartLine()
  )
}

/* ===== Intra: same-function, line-based ===== */
predicate stmtTextHasGuard(Stmt s) {
  exists(Expr e |
    e.getEnclosingStmt() = s and
    e.toString().regexpMatch(
      "(D?CHECK\\(|CSA_ASSERT|DCHECK_EQ|CHECK_EQ"
      + "|Is(Fast|Holey|Double|Smi|SmiOrObject)Elements(Kind)?"
      + "|Has(Fast|Double|Object)Elements|PACKED_(SMI|DOUBLE|ELEMENTS)|HOLEY_(DOUBLE|ELEMENTS)|ElementsKind)"
    )
  )
}

predicate hasGuardBeforeIntra(TransitionCall tc) {
  exists(Stmt st |
    st.getEnclosingFunction() = tc.getEnclosingFunction() and
    st.getLocation().getFile() = tc.getLocation().getFile() and
    st.getLocation().getStartLine() < tc.getLocation().getStartLine() and
    stmtTextHasGuard(st)
  )
  or
  exists(FunctionCall g, Function gf |
    g.getEnclosingFunction() = tc.getEnclosingFunction() and
    g.getTarget() = gf and isGuardFunction(gf) and
    g.getLocation().getFile() = tc.getLocation().getFile() and
    g.getLocation().getStartLine() < tc.getLocation().getStartLine()
  )
}

predicate hasGuardAfterIntra(TransitionCall tc) {
  exists(Stmt st |
    st.getEnclosingFunction() = tc.getEnclosingFunction() and
    st.getLocation().getFile() = tc.getLocation().getFile() and
    st.getLocation().getStartLine() > tc.getLocation().getStartLine() and
    stmtTextHasGuard(st)
  )
  or
  exists(FunctionCall g, Function gf |
    g.getEnclosingFunction() = tc.getEnclosingFunction() and
    g.getTarget() = gf and isGuardFunction(gf) and
    g.getLocation().getFile() = tc.getLocation().getFile() and
    g.getLocation().getStartLine() > tc.getLocation().getStartLine()
  )
}

predicate hasDeoptAfterIntra(TransitionCall tc) {
  exists(FunctionCall g, Function gf |
    g.getEnclosingFunction() = tc.getEnclosingFunction() and
    g.getTarget() = gf and isDeoptFunction(gf) and
    g.getLocation().getFile() = tc.getLocation().getFile() and
    g.getLocation().getStartLine() > tc.getLocation().getStartLine()
  )
}

/* ===== Inter: lightweight reachability (depth <= 4) ===== */
cached predicate calls(Function a, Function b) {
  exists(FunctionCall c | c.getEnclosingFunction() = a and c.getTarget() = b)
}

cached predicate reach1(Function a, Function b) { a = b or calls(a, b) }
cached predicate reach2(Function a, Function b) { reach1(a, b) or exists(Function m | calls(a, m) and reach1(m, b)) }
cached predicate reach3(Function a, Function b) { reach2(a, b) or exists(Function m | calls(a, m) and reach2(m, b)) }
cached predicate reach4(Function a, Function b) { reach3(a, b) or exists(Function m | calls(a, m) and reach3(m, b)) }

predicate reachableBounded(Function a, Function b) { reach4(a, b) }

predicate hasGuardBeforeInter(TransitionCall tc) {
  exists(Function g | isGuardFunction(g) and reachableBounded(g, tc.getEnclosingFunction()))
}

predicate hasGuardAfterInter(TransitionCall tc) {
  exists(Function g | isGuardFunction(g) and reachableBounded(tc.getEnclosingFunction(), g))
}

predicate hasDeoptAfterInter(TransitionCall tc) {
  exists(Function g | isDeoptFunction(g) and reachableBounded(tc.getEnclosingFunction(), g))
}

/* ===== Combined verdicts ===== */
predicate optGate(TransitionCall tc) {
  (requireOpt() and hasOptBeforeIntra(tc)) or not requireOpt()
}

predicate hasGuardBefore(TransitionCall tc) { hasGuardBeforeIntra(tc) or hasGuardBeforeInter(tc) }
predicate hasGuardAfter(TransitionCall tc)  { hasGuardAfterIntra(tc)  or hasGuardAfterInter(tc)  }
predicate hasDeoptAfter(TransitionCall tc)  { hasDeoptAfterIntra(tc)  or hasDeoptAfterInter(tc)  }

/* ===== Labels ===== */
predicate caseLabel(TransitionCall tc, string label) {
  ( not hasGuardBefore(tc) and not hasGuardAfter(tc) and
    label = "CASE 1 — No guards (before/after)" )
  or
  ( hasGuardBefore(tc) and not hasGuardAfter(tc) and
    label = "CASE 2 — Guard only BEFORE (no post-check)" )
  or
  ( not hasGuardBefore(tc) and hasGuardAfter(tc) and
    label = "CASE 3 — Guard only AFTER (state changed before check)" )
  or
  ( hasGuardBefore(tc) and hasGuardAfter(tc) and
    label = "CASE 4 — Guards BOTH before & after" )
}

predicate deoptFlag(TransitionCall tc, string flag) {
  ( hasDeoptAfter(tc)  and flag = " | DeoptAfter=YES" )
  or
  ( not hasDeoptAfter(tc) and flag = " | DeoptAfter=NO" )
}

/* ===== Report (V8 core only) ===== */
from TransitionCall tc, string label, string flag
where optGate(tc)
  and caseLabel(tc, label)
  and deoptFlag(tc, flag)
  and isV8CoreFile(tc.getLocation().getFile())
select tc.getFile().getRelativePath(), tc.getLocation().getStartLine()
