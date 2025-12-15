import cpp

class StoreCellValue extends FunctionCall {
  StoreCellValue() {
    getTarget().getName() = "StoreField" and
    exists(int i, FunctionCall inner |
      i >= 0 and i < getNumberOfArguments() and
      inner = this.getArgument(i) and inner.getTarget().getName() = "ForPropertyCellValue"
    )
  }
}

cached predicate hasGlobalStore(Function f) {
  exists(StoreCellValue st | st.getEnclosingFunction() = f)
  or
  exists(FunctionCall c, Function g |
    c.getEnclosingFunction() = f and c.getTarget() = g and g.getName() = "ReduceJSStoreGlobal"
  )
}

cached predicate hasIsStableInIf(Function f) {
  exists(IfStmt s, FunctionCall c, Function callee |
    s.getEnclosingFunction() = f and
    c.getEnclosingFunction() = f and
    c.getEnclosingStmt() = s and
    c.getTarget() = callee and callee.getName() = "is_stable"
  )
}

from Function f
where hasGlobalStore(f) and hasIsStableInIf(f)
select f.getFile().getRelativePath(), f.getLocation().getStartLine()

