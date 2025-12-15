/**
 * v8_reentrant_ownlookup_positions_bindloc.ql
 *
 * - No direct null checks; bind a concrete Location via 'loc = va.getLocation()'
 * - Reports only the source locations of LookupIterator-like variable uses (VariableAccess)
 *   inside loops that also contain BOTH reentrancy- and mutating-candidate calls.
 */

import cpp

// Reentrancy-candidate calls (proxy/interceptor/prototype-visibility paths).
predicate isReentrantCall(FunctionCall fc) {
  exists(string s |
    s = fc.getTarget().getName() and
    (
      s.matches("%GetOwnPropertyDescriptor%") or
      s.matches("%GetRealNamedPropertyAttributesInPrototypeChain%") or
      s.matches("%NamedPropertyDescriptorCallback%") or
      s.matches("%GetPropertyAttributes%") or
      s.matches("%InvokeNamedPropertyCallback%")
    )
  )
}

// Calls that may mutate object layout / define / normalize properties.
predicate isMutatingCall(FunctionCall fc) {
  exists(string s |
    s = fc.getTarget().getName() and
    (
      s.matches("%CreateDataProperty%") or
      s.matches("%NormalizeProperties%") or
      s.matches("%SetNormalizedProperty%") or
      s.matches("%TransitionToAccessorPair%") or
      s.matches("%SetPropertyWithAccessor%") or
      s.matches("%ReloadPropertyInformation%") or
      s.matches("%DefineOwnPropertyIgnoreAttributes%")
    )
  )
}

// Heuristic: local variable that likely represents a LookupIterator.
predicate isLookupIteratorLocal(LocalVariable lv) {
  exists(Type t |
    t = lv.getType() and
    (t.getName().matches("%LookupIterator%") or lv.getName().matches("%own_lookup%|%lookup%|%OWN%"))
  )
}

// AST containment: statement s is syntactically inside loop (by parent*), excluding the loop node itself.
predicate stmtInsideLoop(Stmt s, Stmt loop) { s.getParent*() = loop and s != loop }

// A call appears inside the loop if its enclosing statement is under the loop.
predicate callInsideLoop(FunctionCall c, Stmt loop) {
  exists(Stmt es | es = c.getEnclosingStmt() and stmtInsideLoop(es, loop))
}

// The loop contains at least one reentrancy-candidate and one mutating-candidate call.
predicate loopHasReentrantAndMutating(Stmt loop) {
  exists(FunctionCall rc | isReentrantCall(rc) and callInsideLoop(rc, loop)) and
  exists(FunctionCall mc | isMutatingCall(mc) and callInsideLoop(mc, loop))
}

// Iterator use site (VariableAccess) for a LookupIterator-like local inside the loop.
predicate iteratorUseInsideLoop(LocalVariable it, Stmt loop, VariableAccess va) {
  va.getTarget() = it and
  exists(Stmt es | es = va.getEnclosingStmt() and stmtInsideLoop(es, loop))
}

// Main: bind only VariableAccess sites with a concrete Location 'loc'
from Stmt loop, VariableAccess va, Location loc
where
  (loop instanceof ForStmt or loop instanceof WhileStmt or loop instanceof DoStmt) and
  loopHasReentrantAndMutating(loop) and
  exists(LocalVariable it | isLookupIteratorLocal(it) and iteratorUseInsideLoop(it, loop, va)) and
  loc = va.getLocation()
select
  va.getFile().getRelativePath(),
  loc.getStartLine()