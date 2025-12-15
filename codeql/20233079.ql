import cpp

/** StoreFastElementBuiltin(...) */
class StoreFastElementBuiltinCall extends FunctionCall {
  StoreFastElementBuiltinCall() {
    this.getTarget().getName().regexpMatch("StoreFastElementBuiltin")
  }

  Expr getStoreMode() { result = this.getArgument(1) }
}

/** The condition that checks for fast elements */
class FastElementsCheck extends Expr {
  FastElementsCheck() {
    this.toString().regexpMatch("has_fast_elements")
  }
}

/** Matches map->IsJSArgumentsObjectMap() */
class ArgumentsMapCheck extends Expr {
  ArgumentsMapCheck() {
    this.toString().regexpMatch("IsJSArgumentsObjectMap")
  }
}

/** store_mode values that imply aggressive fast-path behavior */
class DangerousStoreMode extends Expr {
  DangerousStoreMode() {
    this.toString().regexpMatch("kStore|STORE")
    and not this.toString().regexpMatch("STANDARD_STORE")
  }
}

from StoreFastElementBuiltinCall call, FastElementsCheck fec, DangerousStoreMode sm
where
  // Call happens in same function where fast-elements branch exists
  call.getEnclosingFunction() = fec.getEnclosingFunction()

  // The store mode passed is aggressive (non-standard), unsafe for arguments objects
  and call.getStoreMode().toString() = sm.toString()

  // BUT no IsJSArgumentsObjectMap() guard exists in same branch
  and not exists(ArgumentsMapCheck amc |
      amc.getEnclosingStmt().getParent*() = call.getEnclosingStmt())

select call.getFile().getRelativePath(), call.getLocation().getStartLine()