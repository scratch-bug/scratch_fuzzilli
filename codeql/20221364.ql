/**
 * @name CVE-2022-1364-like materialization / EA invariant risk (single select, Element)
 * @description Finds (1) unsafe FrameState handling without SetEscaped(...) and/or
 *              (2) materialization in Summarize/StackTrace-like paths without guard.
 * @kind problem
 * @id cpp/v8/cve2022-1364-like-risk-single-element
 * @tags security
 */

import cpp

predicate isFrameStateCaseBlock(Stmt s) {
  s.toString().regexpMatch("(?s).*case\\s+IrOpcode::kFrameState\\s*:")
}

predicate marksEscapedInText(Stmt s) {
  s.toString().regexpMatch("(?s).*SetEscaped\\s*\\(")
}

predicate mentionsUnoptimizedFunction(Stmt s) {
  s.toString().regexpMatch("(?s).*FrameStateType::kUnoptimizedFunction.*")
}

predicate isSummarizeLike(Function f) {
  f.getQualifiedName().regexpMatch(".*OptimizedFrame::Summarize.*") or
  f.getName().regexpMatch(".*Summarize.*StackTrace.*")
}

predicate isMaterializeCall(FunctionCall fc) {
  fc.getTarget().getName().regexpMatch("Materialize.*") or
  fc.toString().regexpMatch(".*TranslatedState::Materialize.*")
}

predicate hasMaterializeGuard(Function f) {
  exists(Stmt s |
    s.getEnclosingFunction() = f and
    s.toString().regexpMatch("CHECK\\s*\\(\\s*!.*IsMaterializedObject\\s*\\(")
  )
}

from Element el, string msg
where
  (
    exists(Function f, Stmt caseStmt |
      caseStmt.getEnclosingFunction() = f and
      isFrameStateCaseBlock(caseStmt) and
      mentionsUnoptimizedFunction(caseStmt) and
      not marksEscapedInText(caseStmt) and
      el = caseStmt and
      msg =
        "Unsafe FrameState handling: kFrameState(kUnoptimizedFunction) case without SetEscaped(receiver/function). If reachable from stacktrace/lazy-deopt, this may allow repeated materialization (CVE-2022-1364-like class)."
    )
  )
  or
  (
    exists(Function f, FunctionCall matCall |
      isSummarizeLike(f) and
      matCall.getEnclosingFunction() = f and
      isMaterializeCall(matCall) and
      not hasMaterializeGuard(f) and
      el = matCall and
      msg =
        "Materialization in stacktrace/frame summary path without guard (missing CHECK(!IsMaterializedObject())). Repeated summaries may re-materialize values from same activation."
    )
  )
select el, msg
