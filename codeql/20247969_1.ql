import cpp

predicate isInputUseInfosAssign(Assignment a) {
  a.getLValue().toString().regexpMatch("input_use_infos_\\s*\\[")
}

predicate hasMergeCall(Function f) {
  exists(Call c |
    c.getEnclosingFunction() = f and
    c.getTarget().getName().regexpMatch("(?i)Merge(ToWider|UseInfo|UseInfos)?|WidenUseInfo|MergeUseInfoToWider")
  )
}

from Assignment a
where isInputUseInfosAssign(a) and not hasMergeCall(a.getEnclosingFunction())
select a.getFile().getRelativePath(), a.getLocation().getStartLine()
