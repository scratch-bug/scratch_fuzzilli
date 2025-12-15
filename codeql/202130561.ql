import cpp

/** Calls that add properties: AddProperty/AddDataProperty */
class AddPropertyCall extends FunctionCall {
  AddPropertyCall() {
    exists(string n |
      n = this.getTarget().getName() and
      (
        n = "AddProperty" or
        n = "AddDataProperty" or
        n = "JSObject::AddProperty"
      )
    )
  }
}

/** Calls considered as "existence check" before adding a property */
predicate isExistenceCheck(FunctionCall fc) {
  exists(string n |
    n = fc.getTarget().getName() and
    (
      n = "HasProperty" or
      n = "JSObject::HasProperty" or
      n = "DescriptorArray::Search" or
      n = "DescriptorArray::CheckNameCollisionDuringInsertion" or
      n = "CheckNameCollisionDuringInsertion"
    )
  )
}

/**
 * Report AddProperty-like calls that have no earlier (by source line)
 * existence-check call in the same enclosing function.
 */
from AddPropertyCall addCall, Function enclosing
where
  enclosing = addCall.getEnclosingFunction() and
  not exists(FunctionCall prior |
    prior.getEnclosingFunction() = enclosing and
    isExistenceCheck(prior) and
    prior.getLocation().getStartLine() < addCall.getLocation().getStartLine()
  )
select
  addCall.getFile().getRelativePath(),
  addCall.getLocation().getStartLine()
