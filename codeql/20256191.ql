import cpp

predicate isSigned32(LocalVariable v) {
  v.getType().toString().regexpMatch("(?i)\\bint\\b") and
  not v.getType().toString().regexpMatch("(?i)\\bunsigned\\b")
}

predicate hasAccumulatorPattern(LocalVariable v, Function f) {
  exists(AssignExpr a |
    a.getEnclosingFunction() = f and
    (
      (a.getOperator().toString() = "+=" and a.getLValue().toString().regexpMatch("\\b" + v.getName() + "\\b")) or
      (a.getRValue().toString().regexpMatch("\\b" + v.getName() + "\\b\\s*\\+")) or
      (a.getRValue().toString().regexpMatch("\\+\\s*\\b" + v.getName() + "\\b"))
    )
  )
}

predicate isStringAllocOrFactory(FunctionCall c) {
  exists(Function fun |
    c.getTarget() = fun and
    fun.getQualifiedName().regexpMatch("(?i)(NewRawOneByteString|NewRawTwoByteString|NewString|AllocateRaw|Allocate|String::Allocate|operator new|malloc|realloc|calloc)")
  )
}

predicate callArgMentionsVar(FunctionCall c, LocalVariable v) {
  exists(Expr arg |
    arg = c.getAnArgument() and
    arg.toString().regexpMatch("\\b" + v.getName() + "\\b")
  )
}

from Function f, LocalVariable v, FunctionCall c
where
  v.getFunction() = f and
  isSigned32(v) and
  hasAccumulatorPattern(v, f) and
  c.getEnclosingFunction() = f and
  isStringAllocOrFactory(c) and
  callArgMentionsVar(c, v)
select v.getFile().getRelativePath(), v.getLocation().getStartLine()