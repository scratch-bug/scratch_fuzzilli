/**
 * @name JSToWasmObject called with non-canonicalized ref-index ValueType (textual)
 * @description Flags JSToWasmObject(..., type, ...) where `type` is a local ValueType
 *              and no prior `type.has_index()` guard + reassignment to `type`
 *              is found before the call. (CVE-2024-9859-like)
 * @kind problem
 * @id cpp/v8/jstowasmobject-missing-hasindex-canonicalize-text
 * @tags security
 */

import cpp

class JSToWasmObjectCall extends FunctionCall {
  JSToWasmObjectCall() {
    this.getTarget().getName() = "JSToWasmObject" or
    this.getTarget().getQualifiedName().regexpMatch(".*JSToWasmObject")
  }

  Expr getTypeArg() { result = this.getArgument(2) }
}

predicate isValueTypeLocal(LocalVariable v) {
  v.getType().getUnspecifiedType().getName().regexpMatch(".*ValueType.*")
}

predicate typeArgIsLocalVar(JSToWasmObjectCall c, LocalVariable v) {
  exists(VariableAccess va |
    va = c.getTypeArg() and
    va.getTarget() = v
  ) and isValueTypeLocal(v)
}

predicate hasIndexTextCallOnVar(Function f, LocalVariable v, Call hi) {
  hi.getEnclosingFunction() = f and
  hi.getTarget().getName() = "has_index" and
  hi.toString().regexpMatch(".*\\b" + v.getName() + "\\s*(\\.|->)\\s*has_index\\s*\\(\\s*\\).*")
}

predicate reassignmentToVar(Function f, LocalVariable v, AssignExpr asn) {
  asn.getEnclosingFunction() = f and
  exists(VariableAccess lhs |
    lhs = asn.getLValue() and
    lhs.getTarget() = v
  )
}

predicate hasIndexThenReassignBeforeCall(JSToWasmObjectCall call, LocalVariable v) {
  exists(Function f, Call hi, AssignExpr asn |
    f = call.getEnclosingFunction() and
    hasIndexTextCallOnVar(f, v, hi) and
    reassignmentToVar(f, v, asn) and
    hi.getLocation().getStartLine() < asn.getLocation().getStartLine() and
    asn.getLocation().getStartLine() < call.getLocation().getStartLine()
  )
}

from JSToWasmObjectCall call, LocalVariable typeVar
where
  typeArgIsLocalVar(call, typeVar) and
  not hasIndexThenReassignBeforeCall(call, typeVar)
select call.getFile().getRelativePath(), call.getLocation().getStartLine()
