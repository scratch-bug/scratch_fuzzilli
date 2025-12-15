import cpp

predicate isRepWord(Expr e)  { e.toString().regexpMatch(".*\\bMachineRepresentation::kWord(8|16|32|64)\\b.*") }
predicate isRepFloat(Expr e) { e.toString().regexpMatch(".*\\bMachineRepresentation::kFloat(32|64)\\b.*") }
predicate isRepTagged(Expr e){ e.toString().regexpMatch(".*\\bMachineRepresentation::k(Tagged|CompressedPointer)\\b.*") }
predicate isRepSimd(Expr e)  { e.toString().regexpMatch(".*\\bMachineRepresentation::kSimd128\\b.*") }
predicate isRepOther(Expr e) { e.toString().regexpMatch(".*\\bMachineRepresentation::k[A-Za-z0-9_]+\\b.*")
                               and not isRepWord(e) and not isRepFloat(e) and not isRepTagged(e) and not isRepSimd(e) }

predicate isTypeAny(Expr e)      { e.toString().regexpMatch(".*\\bType::Any\\s*\\(") }
predicate isTypeInt32ish(Expr e) { e.toString().regexpMatch(".*\\bType::(Signed32|Unsigned32)\\s*\\(") }
predicate isTypeSmi(Expr e)      { e.toString().regexpMatch(".*\\bType::(SignedSmall|UnsignedSmall)\\s*\\(") }
predicate isTypeNumberish(Expr e){ e.toString().regexpMatch(".*\\bType::(Number|OrderedNumber|PlainNumber)\\s*\\(")
                                   or e.toString().regexpMatch(".*\\bType::Range\\s*\\(") }
predicate isTypeHeapish(Expr e)  { e.toString().regexpMatch(".*\\bType::(Receiver|Object|String|Symbol|BigInt|Name)\\s*\\(") }
predicate isTypeBool(Expr e)     { e.toString().regexpMatch(".*\\bType::Boolean\\s*\\(") }
predicate isTypeNullish(Expr e)  { e.toString().regexpMatch(".*\\bType::(Null|Undefined)\\s*\\(") }
predicate isTypeOther(Expr e)    { e.toString().regexpMatch(".*\\bType::[A-Za-z0-9_]+\\s*\\(")
                                   and not isTypeAny(e) and not isTypeInt32ish(e) and not isTypeSmi(e)
                                   and not isTypeNumberish(e) and not isTypeHeapish(e) and not isTypeBool(e)
                                   and not isTypeNullish(e) }

predicate compatible(Expr rep, Expr ty) {
  ( isRepWord(rep)  and ( isTypeInt32ish(ty) or isTypeSmi(ty) or isTypeNumberish(ty) or isTypeAny(ty) ) ) or
  ( isRepFloat(rep) and ( isTypeNumberish(ty) or isTypeAny(ty) ) ) or
  ( isRepTagged(rep) and ( isTypeAny(ty) or isTypeHeapish(ty) or isTypeNumberish(ty) ) ) or
  ( isRepSimd(rep)   and ( isTypeAny(ty) ) ) or
  ( isRepOther(rep)  and ( isTypeAny(ty) ) )
}

string repKind(Expr e) {
  result = "word"   and isRepWord(e)  or
  result = "float"  and isRepFloat(e) or
  result = "tagged" and isRepTagged(e)or
  result = "simd"   and isRepSimd(e)  or
  result = "other"
}

string typeKind(Expr e) {
  result = "any"        and isTypeAny(e)      or
  result = "int32ish"   and isTypeInt32ish(e) or
  result = "smi"        and isTypeSmi(e)      or
  result = "numberish"  and isTypeNumberish(e)or
  result = "heapish"    and isTypeHeapish(e)  or
  result = "boolean"    and isTypeBool(e)     or
  result = "nullish"    and isTypeNullish(e)  or
  result = "other"
}

from Call c, Expr repArg, Expr restrArg
where
  repArg = c.getAnArgument() and
  restrArg = c.getAnArgument() and
  repArg != restrArg and
  ( isRepWord(repArg) or isRepFloat(repArg) or isRepTagged(repArg) or isRepSimd(repArg) or isRepOther(repArg) ) and
  ( isTypeAny(restrArg) or isTypeInt32ish(restrArg) or isTypeSmi(restrArg) or
    isTypeNumberish(restrArg) or isTypeHeapish(restrArg) or isTypeBool(restrArg) or
    isTypeNullish(restrArg) or isTypeOther(restrArg) ) and
  not compatible(repArg, restrArg)
select
	restrArg.getFile().getRelativePath(),
  restrArg.getLocation().getStartLine()