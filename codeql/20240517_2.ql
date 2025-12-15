import cpp

class AllocateCall extends Call {
  AllocateCall() {
    exists(Function callee |
      callee = this.getTarget() and
      (callee.getName().regexpMatch("BuildAllocate.*") or
       callee.getQualifiedName().regexpMatch(".*::BuildAllocate.*"))
    )
  }
}

predicate isClearRawAllocation(Call c) {
  exists(Function callee |
    callee = c.getTarget() and
    (callee.getName() = "ClearCurrentRawAllocation" or
     callee.getQualifiedName().regexpMatch(".*::ClearCurrentRawAllocation"))
  )
}

predicate isPotentialGCCall(Call c) {
  exists(Function callee |
    callee = c.getTarget() and
    (
      callee.getName().regexpMatch("(?i)(GC|Garbage|Collect.*Garbage|Scavenge|Evacuat|Mark|Sweep)") or
      callee.getQualifiedName().regexpMatch("(?i)(GC|Garbage|Collect.*Garbage|Scavenge|Evacuat|Mark|Sweep)")
    )
  )
}

from Function f, AllocateCall alloc, Call g
where
  alloc.getEnclosingFunction() = f and
  g.getEnclosingFunction() = f and
  isPotentialGCCall(g) and
  g.getLocation().getFile() = alloc.getLocation().getFile() and
  g.getLocation().getStartLine() > alloc.getLocation().getStartLine() and
  not exists(Call clr |
    isClearRawAllocation(clr) and
    clr.getEnclosingFunction() = f and
    clr.getLocation().getFile() = alloc.getLocation().getFile() and
    clr.getLocation().getStartLine() > alloc.getLocation().getStartLine() and
    clr.getLocation().getStartLine() < g.getLocation().getStartLine()
  )
select alloc.getFile().getRelativePath(), alloc.getLocation().getStartLine()
