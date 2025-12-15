import cpp

/** Only include calls with a resolved function target */
class ResolvedCall extends Call {
  ResolvedCall() { exists(Function t | t = this.getTarget()) }
  Function tgt() { result = this.getTarget() }
}

/** Name matchers (case-insensitive) on symbol names, not on source text */
cached
predicate isBuildAllocateFastObject(ResolvedCall c) {
  exists(string n |
    (n = c.tgt().getName() or n = c.tgt().getQualifiedName()) and
    // e.g., BuildAllocateFastObject or foo::BuildAllocateFastObject
    n.regexpMatch("(?i)(^|::)BuildAllocateFastObject$")
  )
}

cached
predicate isClearCurrentRawAllocation(ResolvedCall c) {
  exists(string n |
    (n = c.tgt().getName() or n = c.tgt().getQualifiedName()) and
    n.regexpMatch("(?i)(^|::)ClearCurrentRawAllocation$")
  )
}

/**
 * Find functions that call BuildAllocateFastObject twice without an
 * intervening ClearCurrentRawAllocation between them (heuristic for missing clear).
 */
from Function fn, ResolvedCall a1, ResolvedCall a2
where
  a1.getEnclosingFunction() = fn and
  a2.getEnclosingFunction() = fn and
  isBuildAllocateFastObject(a1) and
  isBuildAllocateFastObject(a2) and
  a1.getFile() = a2.getFile() and                 // cheap prune
  exists(int l1, int l2 |
    l1 = a1.getLocation().getStartLine() and
    l2 = a2.getLocation().getStartLine() and
    l1 < l2 and
    // no ClearCurrentRawAllocation between a1 and a2
    not exists(ResolvedCall clr, int lc |
      clr.getEnclosingFunction() = fn and
      isClearCurrentRawAllocation(clr) and
      clr.getFile() = a1.getFile() and
      lc = clr.getLocation().getStartLine() and
      l1 < lc and lc < l2
    )
  )
select a2.getFile().getRelativePath(), a2.getLocation().getStartLine()
