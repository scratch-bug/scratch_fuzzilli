import cpp

/**
 * Single SELECT version
 *
 * PURPOSE:
 *   Detect functions that perform size or argument-count calculations
 *   involving bound arguments or argument_count_with_receiver
 *   without proper boundary checks (guards) such as kMaxArguments or kMaxUint16.
 *
 * VULNERABILITY CONTEXT:
 *   Missing guards on argument or bound argument length calculations
 *   can cause integer truncation/overflow and heap corruption in V8.
 *
 * PATTERNS:
 *   A) Function accesses 'bound_arguments' (or its .length / _length variants)
 *      but does NOT contain a local guard using kMaxArguments / kMaxUint16.
 *
 *   B) Function computes 'argument_count + JSCallOrConstructNode::kReceiverOrNewTargetInputCount'
 *      but does NOT contain a local guard using kMaxUint16 / kMaxArguments.
 *
 * COMPATIBILITY:
 *   Uses only Function, IfStmt, and Expr + textual regex matching via toString().
 *   This makes it portable across most CodeQL C++ library versions.
 */

predicate localHasGuard(Function f) {
  // Look for explicit if-condition checks or guard macros referencing max argument constants.
  exists(IfStmt ifs |
    ifs.getEnclosingFunction() = f and
    ifs.getCondition().toString().regexpMatch(
      "(kMaxArguments|Code::kMaxArguments|kMaxUint16|kMaxArgCount|<=\\s*(kMaxArguments|kMaxUint16)|CHECK_LE\\s*\\(|CHECK_GE\\s*\\(|DCHECK_LE|DCHECK_GE)"
    )
  )
  or
  // Also detect any macro calls or constants referencing guards in the body.
  exists(Expr e |
    e.getEnclosingFunction() = f and
    e.toString().regexpMatch(
      "(CHECK_LE|CHECK_GE|DCHECK_LE|DCHECK_GE|ReturnNoChange|NoChange|kMaxArguments|kMaxUint16)"
    )
  )
}

predicate readsBoundArguments(Function f) {
  // Identify functions accessing bound_arguments or its variants.
  exists(Expr e |
    e.getEnclosingFunction() = f and
    e.toString().regexpMatch(
      "\\bbound_arguments\\b|bound_arguments\\s*\\.\\s*length\\s*\\(|\\bbound_arguments_length\\b|\\.\\s*bound_arguments\\s*\\("
    )
  )
}

predicate computesArgumentCountWithReceiver(Function f) {
  // Identify functions computing argument_count_with_receiver pattern.
  exists(Expr e |
    e.getEnclosingFunction() = f and
    e.toString().regexpMatch(
      "argument_count\\s*\\+\\s*JSCallOrConstructNode::kReceiverOrNewTargetInputCount"
    )
  )
}

from Function f, string kind
where
  (
    readsBoundArguments(f) and not localHasGuard(f) and
    kind = "A: bound_arguments access without local guard (kMaxArguments/kMaxUint16)"
  )
  or
  (
    computesArgumentCountWithReceiver(f) and not localHasGuard(f) and
    kind = "B: argument_count + kReceiverOrNewTargetInputCount without local guard (kMaxUint16/kMaxArguments)"
  )
select f.getFile().getRelativePath(), f.getLocation().getStartLine()
