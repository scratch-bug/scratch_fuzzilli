/**
 * @name Missing Next or conditional-only SetSuperProperty after interceptor
 * @description Detects cases where an interceptor call is not followed by an iterator Next(),
 *              or where SetSuperProperty(it, ...) appears only inside conditional blocks.
 * @kind problem
 * @id cpp/v8/interceptor-missing-next-or-conditional-setsuper
 * @tags security
 */

import cpp

/**
 * Interceptor-style calls on JSObject, e.g.,
 *   JSObject::SetPropertyWithInterceptor
 *   JSObject::GetPropertyAttributesWithInterceptor
 *   JSObject::DefinePropertyWithInterceptor
 *
 * These are locations where side effects may modify the LookupIterator state,
 * and therefore require a post-interceptor correction (Next + SetSuperProperty).
 */
class InterceptorCall extends FunctionCall {
  Expr itArg;

  InterceptorCall() {
    this.getTarget().getQualifiedName().regexpMatch(
      "v8::internal::JSObject::(SetPropertyWithInterceptor|GetPropertyAttributesWithInterceptor|DefinePropertyWithInterceptor)"
    ) and
    itArg = this.getArgument(0)
  }

  Expr getIteratorArg() { result = itArg }
  string getIteratorText() { result = itArg.toString() }
}

/**
 * Matches any call whose printed form contains "Next(".
 * This is a textual approximation for detecting iterator->Next() calls.
 * Used because MemberFunctionCall or CFG modules are unavailable.
 */
class NextCall extends Call {
  NextCall() {
    this.toString().matches("%Next(%")
  }
}

/**
 * Matches Object::SetSuperProperty(it, ...)
 * This is the required "safe" post-interceptor store routine
 * that must run on all paths after the interceptor call.
 */
class SetSuperPropertyCall extends FunctionCall {
  Expr itArg;

  SetSuperPropertyCall() {
    this.getTarget().getQualifiedName() = "v8::internal::Object::SetSuperProperty" and
    itArg = this.getArgument(0)
  }

  Expr getIteratorArg() { result = itArg }
  string getIteratorText() { result = itArg.toString() }
}

/**
 * Determines whether a statement is inside any conditional (if/else) context.
 * Used to detect the pattern:
 *
 *   if (...) {
 *       SetSuperProperty(it, ...)
 *   }
 *
 * without any unconditional SetSuperProperty outside the conditional.
 */
predicate isInsideIf(Stmt s) {
  exists(IfStmt ifs |
    s.getParent*() = ifs
  )
}

/**
 * Checks if there exists any iterator->Next() call *after* the interceptor call
 * in the same enclosing function, referring to the same iterator.
 *
 * This models the required iterator state advancement after side effects
 * introduced by the interceptor callback.
 */
predicate hasNextAfter(InterceptorCall ic) {
  exists(NextCall nc |
    nc.getEnclosingFunction() = ic.getEnclosingFunction() and
    nc.getLocation().getStartLine() > ic.getLocation().getStartLine() and
    nc.toString().matches("%" + ic.getIteratorText() + "%")
  )
}

/**
 * Detects whether any SetSuperProperty(it, ...) exists for the same iterator.
 */
predicate hasSetSuper(InterceptorCall ic) {
  exists(SetSuperPropertyCall sc |
    sc.getEnclosingFunction() = ic.getEnclosingFunction() and
    sc.getIteratorText() = ic.getIteratorText()
  )
}

/**
 * Determines if SetSuperProperty(it, ...) exists *only* under conditional blocks
 * and never in an unconditional path.
 *
 * This is the dangerous pattern found in the buggy V8 code:
 *   - SetSuperProperty is called only under certain conditions
 *   - other paths bypass this post-interceptor safe handling
 */
predicate setSuperOnlyConditional(InterceptorCall ic) {
  hasSetSuper(ic) and
  not exists(SetSuperPropertyCall sc2 |
    sc2.getEnclosingFunction() = ic.getEnclosingFunction() and
    sc2.getIteratorText() = ic.getIteratorText() and
    not isInsideIf(sc2.getEnclosingStmt())
  )
}

/**
 * Report cases where:
 *   (A) There is no iterator Next() after the interceptor call, OR
 *   (B) SetSuperProperty(it, ...) is only present under conditional blocks.
 */
from InterceptorCall ic
where
  not hasNextAfter(ic)
  or
  setSuperOnlyConditional(ic)
select ic.getFile().getRelativePath(), ic.getLocation().getStartLine()
