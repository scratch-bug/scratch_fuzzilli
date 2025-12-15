import cpp

predicate isPropertyExistenceCheck(FunctionCall c) {
  exists(Function f |
    f = c.getTarget() and
    f.getName().regexpMatch("HasRealNamedProperty|HasProperty")
  )
}

predicate isGlobalStyleReceiver(Expr e) {
  e.toString().regexpMatch(".*WebAssembly.*")
  and not e.toString().regexpMatch(".*wasm_webassembly_object.*")
}

predicate isContextCachedReceiver(Expr e) {
  e.toString().regexpMatch(".*wasm_webassembly_object.*")
}

predicate functionUsesGlobalAndContext(Function f) {
  exists(Expr eg, Expr ec |
    eg.getEnclosingFunction() = f and
    ec.getEnclosingFunction() = f and
    isGlobalStyleReceiver(eg) and
    isContextCachedReceiver(ec)
  )
}

predicate hasGuardOnGlobal(Function f) {
  exists(FunctionCall c, Expr recv |
    c.getEnclosingFunction() = f and
    isPropertyExistenceCheck(c) and
    recv = c.getArgument(0) and
    isGlobalStyleReceiver(recv)
  )
}

predicate hasGuardOnContext(Function f) {
  exists(FunctionCall c, Expr recv |
    c.getEnclosingFunction() = f and
    isPropertyExistenceCheck(c) and
    recv = c.getArgument(0) and
    isContextCachedReceiver(recv)
  )
}

from Function f
where
  functionUsesGlobalAndContext(f) and
  hasGuardOnGlobal(f) and
  not hasGuardOnContext(f)
select f.getFile().getRelativePath(), f.getLocation().getStartLine()