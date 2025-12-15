import cpp

/** AccessorInfo getters (internal native getters) */
class NativeGetter extends FunctionCall {
  NativeGetter() {
    this.getTarget().getName().regexpMatch("MakeAccessor|Accessor|InstallAccessor")
     and this.getFile().toString().regexpMatch("v8|object|property|runtime")
  }

  Expr getGetterFunc() { result = this.getArgument(2) } // arg(2) = getter
}

/** JS execution inside a C++ callback getter */
class JSExecution extends FunctionCall {
  JSExecution() {
    this.getTarget().getName().regexpMatch(
      "Call|Invoke|CallJS|JSCall|Builtin|PrepareStackTrace|DeleteProperty|DefineOwnProperty"
    )
    and this.getFile().toString().regexpMatch("v8")
  }
}

/** V8 uses *data property attributes* even for AccessorInfo-based properties */
class SuspiciousAttributes extends Expr {
  SuspiciousAttributes() {
    this.toString().regexpMatch("writable|configurable|enumerable")
  }
}

from NativeGetter ng, JSExecution js, SuspiciousAttributes attrs
where
  // same file (same builtin)
  ng.getFile() = js.getFile() and

  // JS execution happens in the same enclosing function as the getter install
  js.getEnclosingFunction() = ng.getEnclosingFunction() and

  // JS-visible attributes appear in same function as getter install
  attrs.getEnclosingFunction() = ng.getEnclosingFunction()

select ng.getFile().getRelativePath(), ng.getLocation().getStartLine()