import cpp

from FunctionCall c, Function f, File file, int line
where
  c.getTarget() = f and
  f.getName().regexpMatch("^Is(?:Signed|Unsigned|Float|Double|Word(?:32|64))$") and
  file = c.getLocation().getFile() and
  line = c.getLocation().getStartLine() and
  forall(FunctionCall o |
    o.getTarget() = f and
    o.getLocation().getFile() = file and
    o.getLocation().getStartLine() = line
    implies o.getLocation().getStartColumn() >= c.getLocation().getStartColumn()
  )
select c.getFile().getRelativePath(), c.getLocation().getStartLine()