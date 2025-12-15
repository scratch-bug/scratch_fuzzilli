import cpp

/*
 * Order-check probe (lightweight):
 * Find occurrences inside ValueDeserializer::ReadJSObjectProperties where:
 *  - there is a call to Map::Update(...)
 *  - there is a call to CommitProperties(...)
 *  - and CommitProperties' start line is after Map::Update's start line
 *
 * This uses simple line-number comparison to enforce "Update then CommitProperties".
 * File-path regex narrows scope to deserialization/value sources for speed.
 */
from Function f, FunctionCall u, FunctionCall c
where
  // Target the exact method by qualified name
  f.getQualifiedName().regexpMatch(".*ValueDeserializer::ReadJSObjectProperties$") and

  // Constrain to likely deserializer/value source files to keep the search fast
  f.getFile().getRelativePath().regexpMatch(".*/(deserial|value).*\\.(cc|cpp)$") and

  // Both calls must be inside the same function
  u.getEnclosingFunction() = f and
  c.getEnclosingFunction() = f and

  // u is a call to Map::Update(...)
  exists(Function tu |
    tu = u.getTarget() and tu.getQualifiedName().regexpMatch(".*::Map::Update$")
  ) and

  // c is a call to CommitProperties(...)
  c.getTarget().getName() = "CommitProperties" and

  // Lightweight ordering heuristic: CommitProperties appears after Map::Update (by start line)
  c.getLocation().getStartLine() > u.getLocation().getStartLine()
select c.getFile().getRelativePath(), c.getLocation().getStartLine()
