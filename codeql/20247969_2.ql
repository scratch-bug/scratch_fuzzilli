import cpp

predicate looksLikeUseInfoRef(Expr e) {
  e.toString().regexpMatch("(?i)\\binput_use_info\\b|\\buse_info\\b|input_use_infos_\\s*\\[")
}

predicate isLValue(Expr e) {
  exists(Assignment a | a.getLValue() = e)
  or exists(UnaryOperation u | u.getOperator() = "&" and u.getOperand() = e)
}

predicate isUseInfoRead(Expr e) {
  looksLikeUseInfoRef(e) and not isLValue(e)
}

predicate isUseLessGeneralCheck(Call c) {
  c.getTarget().getName().regexpMatch("(?i)IsUseLessGeneral|IsUseLessGeneralOf|IsLessGeneral")
  or c.toString().regexpMatch("(?i)DCHECK\\s*\\(.*IsUseLessGeneral")
}

predicate beforeInSameFile(Element a, Element b) {
  a.getLocation().getFile() = b.getLocation().getFile() and
  a.getLocation().getStartLine() < b.getLocation().getStartLine()
}

from Function f, Expr useSite, string kind, Element anchor
where
  useSite.getEnclosingFunction() = f and
  isUseInfoRead(useSite) and
  (
    exists(Call c |
      c.getEnclosingFunction() = f and
      isUseLessGeneralCheck(c) and
      beforeInSameFile(useSite, c) and
      kind = "after-check" and
      anchor = c
    )
    or
    (
      not exists(Call c2 | c2.getEnclosingFunction() = f and isUseLessGeneralCheck(c2)) and
      kind = "no-check" and
      anchor = useSite
    )
  )
select
  useSite.getFile().getRelativePath(), useSite.getLocation().getStartLine()