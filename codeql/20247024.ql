/**
 * @name V8 Wasm func_ref/call_target + kOld allocation + untrusted WasmFuncRef usages
 * @description Flags three CVE-2024-7024-like patterns under src/:
 *  (1) call_target resolved through func_ref chain
 *  (2) AllocationType::kOld used in allocation paths
 *  (3) WasmFuncRef fields declared in non-trusted-looking objects (heuristic)
 * @kind select
 * @id cpp/v8/wasm-funcref-calltarget-oldalloc-untrusted
 * @tags security
 */

import cpp

predicate inSrc(Element n) {
  n.getFile().getRelativePath().regexpMatch("^src/.*")
}

predicate isFuncRefCallTargetAccess(FieldAccess fa) {
  fa.getTarget().getName() = "call_target" and
  fa.getQualifier().toString().regexpMatch(".*func_ref.*")
}

predicate isOldAllocationExpr(Expr e) {
  e.toString().regexpMatch(".*AllocationType::kOld.*")
}

predicate isUntrustedWasmFuncRefField(MemberVariable mv) {
  mv.getType().getUnspecifiedType().getName().regexpMatch(".*WasmFuncRef.*") and
  not mv.getDeclaringType().getName().regexpMatch(".*Trusted.*") and
  not mv.getDeclaringType().getQualifiedName().regexpMatch(".*(ExposedTrustedObject|TrustedObject).*")
}

from Element n
where
  inSrc(n) and
  (
    exists(FieldAccess fa |
      isFuncRefCallTargetAccess(fa) and
      n = fa
    )
    or
    exists(Expr ex |
      isOldAllocationExpr(ex) and
      n = ex
    )
    or
    exists(MemberVariable mv |
      isUntrustedWasmFuncRefField(mv) and
      n = mv
    )
  )
select n.getFile().getRelativePath(), n.getLocation().getStartLine()
