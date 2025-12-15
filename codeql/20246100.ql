/**
 * Detect uses of ValueType ref-paths (20-bit HeapType encoding) where the
 * argument appears to come from canonical-like containers (heuristic)
 * and the enclosing function does NOT contain a CheckMaxCanonicalIndex/
 * kV8MaxWasmTypes-style guard.
 *
 * Strategy:
 *  - Find calls to ValueType::RefMaybeNull / ValueType::Ref / ValueType::RefNull
 *    and HeapTypeField::encode.
 *  - Heuristically require that the call text contains a canonical-like token
 *    (isorecursive_canonical_type_ids or canonical_supertypes_ or "canonical").
 *    (This reduces noise; remove the heuristic if you want broader coverage.)
 *  - Ensure the enclosing function does NOT contain a textual guard:
 *    CheckMaxCanonicalIndex(, kV8MaxWasmTypes, DCHECK_LE(...kMaxCanonicalTypes) etc.
 *
 * Notes:
 *  - This is a heuristic detector (string/AST mixed). It finds suspicious spots
 *    that should be manually audited. For higher precision, use dataflow if your
 *    CodeQL supports semmle.cpp.dataflow.
 */

import cpp

/**
 * Helper predicate: does the given function appear to contain a guard
 * that would prevent canonical-id overflow / truncation?
 * We look for a few textual patterns that indicate a guard exists.
 */
predicate hasCanonicalGuard(Function f) {
  exists(Call guard |
    guard.getEnclosingFunction() = f and
    guard.toString().regexpMatch(
      "(?i)(CheckMaxCanonicalIndex\\s*\\(|\\bkV8MaxWasmTypes\\b|\\bCheckMaxCanonicalIndex\\b|DCHECK_LE\\s*\\([^)]*kMaxCanonicalTypes|<=\\s*kV8MaxWasmTypes|<\\s*kV8MaxWasmTypes)"
    )
  )
}

/**
 * Main query: suspicious sink calls without local guard.
 */
from Call sinkCall, Function callee, Function encl
where
  // bind
  sinkCall.getTarget() = callee and
  encl = sinkCall.getEnclosingFunction() and

  // sink candidates: ValueType ref-constructors or HeapTypeField::encode
  (
    callee.getQualifiedName().regexpMatch("(^|::)ValueType::RefMaybeNull($|::)")
    or callee.getQualifiedName().regexpMatch("(^|::)ValueType::Ref($|::)")
    or callee.getQualifiedName().regexpMatch("(^|::)ValueType::RefNull($|::)")
    or callee.getQualifiedName().regexpMatch("(^|::)HeapTypeField::encode($|::)")
  )

  // heuristic: the call text contains canonical-like tokens (reduces noise)
  and sinkCall.toString().regexpMatch("(?i)(isorecursive_canonical_type_ids|canonical_supertypes_|\\bcanonical\\b)")

  // the enclosing function does NOT have a guard
  and not hasCanonicalGuard(encl)

  // optionally restrict to likely wasm area to reduce false positives:
select sinkCall.getFile().getRelativePath(), sinkCall.getLocation().getStartLine()