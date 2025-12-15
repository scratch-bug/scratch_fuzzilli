import cpp

/*
 * Presence-only probe (narrow scope):
 * Assert that ValueDeserializer::ReadJSObjectProperties contains BOTH:
 *  - a call to Map::Update(isolate, target)
 *  - a call to CommitProperties(...)
 * The file-path regex confines matches to deserializer/value sources for speed.
 */
from Function f
where
  // Target the exact method by qualified name
  f.getQualifiedName().regexpMatch(".*ValueDeserializer::ReadJSObjectProperties$") and

  // Constrain to likely deserializer/value source files to keep search fast
  f.getFile().getRelativePath().regexpMatch(".*/(deserial|value).*\\.(cc|cpp)$") and

  // Exists: call to Map::Update(...)
  exists(FunctionCall u |
    u.getEnclosingFunction() = f and
    exists(Function tu |
      tu = u.getTarget() and tu.getQualifiedName().regexpMatch(".*::Map::Update$")
    )
  ) and

  // Exists: call to CommitProperties(...)
  exists(FunctionCall c |
    c.getEnclosingFunction() = f and c.getTarget().getName() = "CommitProperties"
  )
select f.getFile().getRelativePath(), f.getLocation().getStartLine()
