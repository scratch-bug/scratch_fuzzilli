import cpp

/* A lightweight pattern class that matches calls whose resolved target
   function symbol's name is "RecordThisUse". This lets us find direct
   invocations even when the call is represented as a FunctionCall. */
class RecordThisUseCall extends FunctionCall {
  RecordThisUseCall() {
    exists(Function target |
      target = this.getTarget() and
      target.getName() = "RecordThisUse"
    )
  }
}

/* Main query:
   - For each Function `f` and each call `call` that matches RecordThisUseCall,
   - Restrict to functions that look like parser code: either the function
     name contains "Parse" (case-insensitive) or the source file path
     contains "/parsing/" or "parser" (case-insensitive).
   - Additionally require that the enclosing function `f` does NOT declare
     any local variable whose static type name is "FunctionParsingScope".
     (This finds RecordThisUse invocations on paths where there is no
     FunctionParsingScope local.)
   - Report the call and its location.
*/
from Function f, RecordThisUseCall call
where
  call.getEnclosingFunction() = f and
  (
    f.getName().regexpMatch("(?i).*Parse.*") or
    exists(File fi | fi = f.getFile() and fi.getRelativePath().regexpMatch("(?i).*(/parsing/|parser).*"))
  )
  and not exists(LocalVariable fps |
    fps.getFunction() = f and
    fps.getType().getUnspecifiedType().getName() = "FunctionParsingScope"
  )
select call.getFile().getRelativePath(), call.getLocation().getStartLine()
