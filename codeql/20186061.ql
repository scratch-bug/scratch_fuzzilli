import cpp

class ValidateLikeFunction extends Function {
  ValidateLikeFunction() {
    this.getName().regexpMatch("(?i).*SyncValidate.*") and
    this.getFile().getRelativePath().regexpMatch(".*wasm.*")
  }
}

predicate hasSharedFlagInFunction(Function f) {
  exists(Variable v |
    v.getParentScope() = f and
    v.getType() instanceof BoolType and
    v.getName().regexpMatch("(?i)shared")
  )
  or
  exists(Parameter p |
    p.getFunction() = f and
    p.getType() instanceof BoolType and
    p.getName().regexpMatch("(?i)shared")
  )
}

from FunctionCall call, ValidateLikeFunction vf, Function enclosing
where
  call.getTarget() = vf and
  enclosing = call.getEnclosingFunction() and
  not hasSharedFlagInFunction(enclosing)
select call.getFile().getRelativePath(), call.getLocation().getStartLine()