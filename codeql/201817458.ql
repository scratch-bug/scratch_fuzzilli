/**
 * @name V8 Wasm imported-table dispatch propagation uses wrong instance (table)
 * @description Same detection as CVE-2018-17458 pattern, but emitted as a table query
 *              so raw file/line columns are allowed.
 * @kind table
 * @id cpp/v8/wasm/imported-table-wrong-instance-propagation-table
 * @tags security
 */

import cpp

class ImportedFunctionEntryCtor extends ConstructorCall {
  ImportedFunctionEntryCtor() {
    this.getTarget().getDeclaringType().getName() = "ImportedFunctionEntry"
  }
}

class ImportedEntryInstanceCall extends FunctionCall {
  ImportedEntryInstanceCall() {
    this.getTarget().getName() = "instance" and
    this.getTarget().getDeclaringType().getName() = "ImportedFunctionEntry"
  }
}

class UpdateDispatchTablesCall extends FunctionCall {
  UpdateDispatchTablesCall() {
    this.getTarget().getName() = "UpdateDispatchTables" and
    this.getTarget().getDeclaringType().getName() = "WasmTableObject"
  }
}

predicate passesOriginalInstance(UpdateDispatchTablesCall c, Expr origInst) {
  c.getNumberOfArguments() >= 5 and
  c.getArgument(4) = origInst
}

from
  Function f,
  ImportedFunctionEntryCtor ctor,
  ImportedEntryInstanceCall instRead,
  UpdateDispatchTablesCall upd,
  Expr origInst
where
  ctor.getEnclosingFunction() = f and
  instRead.getEnclosingFunction() = f and
  upd.getEnclosingFunction() = f and
  origInst = ctor.getArgument(0) and
  passesOriginalInstance(upd, origInst)

select upd.getFile().getRelativePath(), upd.getLocation().getStartLine()