import cpp

/*
 * Guard-missing probe:
 * Inside ValueDeserializer::ReadJSObjectProperties, find a Map::Update(...) call
 * followed later (by source order) by CommitProperties(...), with NO intervening
 * guard/check calls such as Normalize / IsDictionaryMap / is_dictionary_map /
 * CanHaveMoreTransitions between them. This suggests a potential fast-vs-dictionary
 * assumption mismatch at commit time.
 */
from Function f, FunctionCall u, FunctionCall c
where
  // Target function (limit to likely deserializer/value source files for speed)
  f.getQualifiedName().regexpMatch(".*ValueDeserializer::ReadJSObjectProperties$") and
  f.getFile().getRelativePath().regexpMatch(".*/(deserial|value).*\\.(cc|cpp)$") and

  // Both calls occur within the same function
  u.getEnclosingFunction() = f and
  c.getEnclosingFunction() = f and

  // u is Map::Update(...)
  exists(Function tu |
    tu = u.getTarget() and tu.getQualifiedName().regexpMatch(".*::Map::Update$")
  ) and

  // c is CommitProperties(...), and it appears after u (by start line)
  c.getTarget().getName() = "CommitProperties" and
  c.getLocation().getStartLine() > u.getLocation().getStartLine() and

  // No guard/check calls appear between u and c
  not exists(FunctionCall g |
    g.getEnclosingFunction() = f and
    g.getLocation().getStartLine() > u.getLocation().getStartLine() and
    g.getLocation().getStartLine() < c.getLocation().getStartLine() and
    exists(Function tg |
      tg = g.getTarget() and
      (
        tg.getName() = "Normalize" or
        tg.getName() = "IsDictionaryMap" or
        tg.getName() = "is_dictionary_map" or
        tg.getName() = "CanHaveMoreTransitions"
      )
    )
  )
	select c.getFile().getRelativePath(), c.getLocation().getStartLine()