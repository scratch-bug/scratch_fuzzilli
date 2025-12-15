import cpp

/**
 * Same-function heuristic:
 *  - one or more calls named like IsOneByteRepresentation(...)
 *  - and later a call named like GetCharVector/CopyChars/JsonParser/SerializeString_
 *  - and nowhere in the same function a call named like IsOneByteRepresentationUnderneath(...)
 */

from Function f, Call check, Call access
where
  check.getEnclosingFunction() = f and
  access.getEnclosingFunction() = f and

  exists(Function cal1 |
    cal1 = check.getTarget() and
    cal1.getName().regexpMatch(".*IsOneByteRepresentation.*")
  ) and

  exists(Function cal2 |
    cal2 = access.getTarget() and
    (
      cal2.getName().regexpMatch(".*GetCharVector.*") or
      cal2.getName().regexpMatch(".*CopyChars.*") or
      cal2.getName().regexpMatch(".*JsonParser.*") or
      cal2.getName().regexpMatch(".*SerializeString_.*")
    )
  ) and

  not exists(Call safe, Function calSafe |
    safe.getEnclosingFunction() = f and
    calSafe = safe.getTarget() and
    calSafe.getName().regexpMatch(".*IsOneByteRepresentationUnderneath.*")
  ) and

  check.getLocation().getStartLine() < access.getLocation().getStartLine()

select check.getFile().getRelativePath(), check.getLocation().getStartLine()