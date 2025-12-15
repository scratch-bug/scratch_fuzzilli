/**
 * Same logic as before but WITHOUT initial file-path regex filter.
 * Safety mitigations:
 *  - require decodeCall to be in the *same file* as NextWithValue
 *  - prefer getTarget()/callee name matching to avoid expensive toString() on many nodes
 *  - limit textual toString() use to specific nodes (decodeCall and rel)
 */

import cpp

from Function nextMethod, Call decodeCall
where
  // target function name
  nextMethod.getName() = "NextWithValue"

  // require decodeCall to be in the same file as nextMethod (keeps locality)
  and decodeCall.getEnclosingFunction().getFile() = nextMethod.getFile()

  // decodeCall must target DecodeVarInt32 (prefer resolved symbol)
  and exists(Function callee | decodeCall.getTarget() = callee and callee.getName().regexpMatch("(?i)DecodeVarInt32"))
  // fallback textual check only on the decodeCall itself (limited scope)
  and decodeCall.toString().regexpMatch("(?i)max_module_size")

  // but NextWithValue does NOT contain a relational expression that mentions both token classes
  and not exists(Expr rel |
    rel.getEnclosingFunction() = nextMethod
    and rel.toString().regexpMatch("(?i)(<=|<|>=|>)")
    and rel.toString().regexpMatch("(?i)\\b(module_offset|module_offset_|moduleOffset|payload_start|payloadStart|streaming->module_offset)\\b")
    and rel.toString().regexpMatch("(?i)\\b(max_module_size|wasm_max_module_size|kV8MaxWasmModuleSize|max_size)\\b")
  )

select nextMethod.getFile().getRelativePath(), nextMethod.getLocation().getStartLine()