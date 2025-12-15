import cpp

/** calls inside V8 that check a property on an object */
class CheckCall extends FunctionCall {
  CheckCall() {
    this.toString().regexpMatch("Has|Check|Lookup|GetOwnProperty|HasProperty|HasKey")
      and this.getFile().toString().regexpMatch("v8|src")
  }

  Expr getObj() { result = this.getArgument(0) }
}

/** calls that install/define/transition properties */
class InstallCall extends FunctionCall {
  InstallCall() {
    this.toString().regexpMatch(
      "Define|Install|Create|SetProperty|Transition|AddDataProperty|FastProperty"
    )
    and this.getFile().toString().regexpMatch("v8|src")
  }

  Expr getObj() { result = this.getArgument(0) }
}

from CheckCall check, InstallCall install
where
  // same file to keep it relevant
  check.getFile() = install.getFile() and

  // check target object != install target object (string compare to stay permissive)
  check.getObj().toString() != install.getObj().toString()

select install.getFile().getRelativePath(), install.getLocation().getStartLine()