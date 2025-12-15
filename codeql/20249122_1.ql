import cpp

predicate looksLikeIsCanonicalSubtypeCall(Call c) {
  exists(Function f |
    c.getTarget() = f and
    (
      f.getName().regexpMatch("(?i)IsCanonicalSubtype") or
      f.getQualifiedName().regexpMatch("(?i)IsCanonicalSubtype")
    )
  )
  or c.toString().regexpMatch("(?i)type_canonicalizer\\s*\\(\\)\\s*->\\s*IsCanonicalSubtype")
  or c.toString().regexpMatch("(?i)\\bIsCanonicalSubtype\\s*\\(")
}

from Function enclosing, Call c
where looksLikeIsCanonicalSubtypeCall(c) and c.getEnclosingFunction() = enclosing
select c.getFile().getRelativePath(), c.getLocation().getStartLine()