import cpp

class NarrowingFunction extends Function {
  NarrowingFunction() {
    this.getName().regexpMatch(".*TruncateInt64ToInt32.*") or
    this.getName().regexpMatch(".*ChangeInt64ToInt32.*")
  }
}

class TypeCheckCall extends FunctionCall {
  TypeCheckCall() {
    // Matches TypeCheckKind::kXXX expressions
    exists(Expr arg |
      arg = this.getAnArgument() and
      arg.getType().getUnspecifiedType().toString().regexpMatch("TypeCheckKind")
    )
  }
}

from FunctionCall c, NarrowingFunction nf
where
  // narrowing function appears
  c.getTarget() = nf and

  // ensure this narrowing occurs inside a V8 lowering / representation file
  c.getFile().getRelativePath().
    regexpMatch(".*(simplified-lowering|representation-changer).*") and

  // ensure NO TypeCheckKind is used in nearby conditions
  not exists(TypeCheckCall tc |
    tc.getEnclosingStmt() = c.getEnclosingStmt() or
    tc.getEnclosingStmt().getParent*() = c.getEnclosingStmt()
  )

select c.getFile().getRelativePath(), c.getLocation().getStartLine()