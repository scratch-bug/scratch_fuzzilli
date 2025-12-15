import cpp

from Function f, Call call
where
  call.getEnclosingFunction() = f and
  call.getTarget().getName().regexpMatch("max_module_size") and
  not exists(Expr e |
    e.getEnclosingFunction() = f and
    e.toString().regexpMatch("(?i)\\b(module_offset|module_offset_|moduleOffset|payload_start|payloadStart|payload_start_|streaming->module_offset|streaming->moduleOffset)\\b")
  )
select call.getFile().getRelativePath(), call.getLocation().getStartLine()