/**
 * @name Potential missing-zero-guard in integer-only typing guard
 * @description Finds if-conditions that narrow an increment/step type to kInteger
 *              without guarding against kSingletonZero in the same if-condition.
 * @kind problem
 * @id cpp/v8/increment-integer-without-zero-guard
 * @tags security
 */

import cpp

class IntegerIsCall extends ExprCall {
  Expr q;

  IntegerIsCall() {
    this.getTarget().getName() = "Is" and
    this.getNumberOfArguments() = 1 and
    this.getArgument(0).toString().regexpMatch(".*kInteger.*") and
    q = this.getQualifier()
  }

  Expr getQ() { result = q }
}

class ZeroIsCall extends ExprCall {
  Expr q;

  ZeroIsCall() {
    this.getTarget().getName() = "Is" and
    this.getNumberOfArguments() = 1 and
    this.getArgument(0).toString().regexpMatch(".*kSingletonZero.*|.*SingletonZero.*") and
    q = this.getQualifier()
  }

  Expr getQ() { result = q }
}

predicate isIncrementLikeVar(Expr e) {
  exists(Variable v |
    e instanceof VariableAccess and
    v = e.(VariableAccess).getTarget() and
    v.getName().regexpMatch("(?i).*(increment|inc|step|delta).*")
  )
}

from IfStmt ifs, IntegerIsCall intIs, Expr q
where
  intIs.getEnclosingStmt() = ifs and
  q = intIs.getQ() and
  isIncrementLikeVar(q) and

  not exists(ZeroIsCall z |
    z.getEnclosingStmt() = ifs and
    z.getQ().toString() = q.toString()
  )
select ifs.getFile().getRelativePath(), ifs.getLocation().getStartLine()