import cpp

class V8Function extends Function {
  V8Function() {
    this.getQualifiedName().regexpMatch("v8::internal::.*")
  }
}

class BuilderLikeFunction extends V8Function {
  BuilderLikeFunction() {
    this.getFile().getRelativePath().regexpMatch(".*src/wasm/.*") and
    this.getQualifiedName().regexpMatch(".*(Builder|Instantiate|ProcessImports|Install).*")
  }
}

class JsExecutionCall extends FunctionCall {
  JsExecutionCall() {
    exists(Function f |
      this.getTarget() = f and
      f.getQualifiedName().regexpMatch("v8::internal::Execution::(Call|TryCall)")
    )
  }
}

predicate writesBuilderState(BuilderLikeFunction f, FieldAccess fa) {
  fa.getEnclosingFunction() = f and
  exists(Field field |
    fa.getTarget() = field and
    field.getDeclaringType() = f.getDeclaringType()
  )
}

predicate hasStateWriteBefore(BuilderLikeFunction f, JsExecutionCall call) {
  exists(FieldAccess fa |
    writesBuilderState(f, fa) and
    fa.getLocation().getStartLine() < call.getLocation().getStartLine()
  )
}

predicate hasStateUseAfter(BuilderLikeFunction f, JsExecutionCall call) {
  exists(Expr e |
    e.getEnclosingFunction() = f and
    e.getLocation().getStartLine() > call.getLocation().getStartLine()
  )
}

from BuilderLikeFunction f, JsExecutionCall call
where
  call.getEnclosingFunction() = f and
  hasStateWriteBefore(f, call) and
  hasStateUseAfter(f, call)
select call.getFile().getRelativePath(), call.getLocation().getStartLine()
