import cpp

class CacheType extends Class {
  CacheType() { this.getName().matches("%Cache%") }
}

class CacheLookupCall extends FunctionCall {
  CacheLookupCall() {
    this.getTarget().getDeclaringType() instanceof CacheType and
    this.getTarget().getName().regexpMatch("Lookup|Find|Get.*Wrapper|Get.*Code")
  }
}

class IncRefCall extends FunctionCall {
  IncRefCall() { this.getTarget().getName() = "IncRef" }
}

predicate hasDyingGate(Function f) {
  exists(FunctionCall g |
    g.getEnclosingFunction() = f and
    (
      g.getTarget().getName().regexpMatch("IncRefIfNotDying|is_dying") or
      g.toString().regexpMatch("kIsDyingMask")
    )
  )
}

from Function f, CacheLookupCall lookup, AssignExpr asg, IncRefCall inc
where
  lookup.getEnclosingFunction() = f and
  asg.getEnclosingFunction() = f and
  inc.getEnclosingFunction() = f and

  asg.getRValue() = lookup and

  inc.toString().regexpMatch(
    ".*" + asg.getLValue().toString() + ".*IncRef\\s*\\("
  ) and

  not hasDyingGate(f)
select inc.getFile().getRelativePath(), inc.getLocation().getStartLine()