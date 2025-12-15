import cpp

from Function f, IfStmt guard, Expr e
where
  guard.getEnclosingFunction() = f and
  e.getEnclosingFunction() = f and

  // Check if the condition expression contains 'is_stable(' (a cheap text-based pattern)
  guard.getCondition().toString().regexpMatch("\\bis_stable\\s*\\(") and

  // Ensure that no type guard keywords are present (simple negation filter)
  not guard.getCondition().toString().regexpMatch("\\bIsJS(Object|Receiver|HeapObjectType|Smi)\\b") and

  // Verify that '.AsJSObject(' exists somewhere within the same function
  e.toString().regexpMatch("\\.AsJSObject\\s*\\(")

select guard.getFile().getRelativePath(), guard.getLocation().getStartLine()
