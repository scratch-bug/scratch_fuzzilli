/**
 * expanded-getcurrent-casts.ql
 *
 * Single-query, widened candidate set for:
 *  - GetCurrent-like calls (GetCurrent<...>(), Current<...>(), GetPrototype*)
 *  - Direct JSObject casts (JSObject::cast, Handle<JSObject>::cast, static_cast<JSObject>)
 *  - Inline casts where GetCurrent result is casted inline
 *
 * For GetCurrent-like calls we additionally flag when the enclosing function
 * does NOT contain obvious textual guards (IsJSObject/IsWasmObject/IsJSProxy/etc).
 *
 * Usage:
 *   codeql query run --database=<db> expanded-getcurrent-casts.ql
 */

import cpp

// -----------------------------
// Guard-text heuristic (tweak regex to your repo's guard names if needed)
// -----------------------------
private predicate hasGuardText(Stmt s) {
  s.toString().regexpMatch(
    "(IsJSObject\\s*\\(|IsJSProxy\\s*\\(|IsWasmObject\\s*\\(|IsJSReceiver\\s*\\(|CheckJSObject\\s*\\(|CheckPrototypeIsJSObject\\s*\\(|CheckMaps\\s*\\(|TryBuildMapGuard\\s*\\()"
  )
}

// -----------------------------
// isGetCurrentLikeCall: 넓은 후보군
// - GetCurrent<T>(), iter.GetCurrent<T>(), Current<T>(), GetPrototype<T>(), GetPrototypeObject<T>()
// - 템플릿 표기뿐 아니라 멤버 호출 형태도 포괄
// -----------------------------
predicate isGetCurrentLikeCall(Call c) {
  // match target names first (safe)
  c.getTarget().getName().regexpMatch("(GetCurrent|Current|GetPrototype|GetPrototypeObject)")
  and
  // textual confirmation that template/member usage exists (helps avoid unrelated calls)
  c.toString().regexpMatch(
    "(GetCurrent\\s*<)|(Current\\s*<)|(GetPrototype\\s*<)|(GetPrototypeObject\\s*<)|(\\.\\s*(GetCurrent|Current|GetPrototype|GetPrototypeObject)\\s*<)"
  )
}

// -----------------------------
// Direct cast detection (calls that perform casts to JSObject)
// - JSObject::cast(...)
// - Handle<JSObject>::cast(...)
// - static_cast<JSObject>(...)
// -----------------------------
predicate isDirectJSObjectCast(Call c) {
  c.toString().regexpMatch(
    "(JSObject::cast\\s*\\()|((Handle\\s*<\\s*JSObject\\s*>)\\s*::\\s*cast\\s*\\()|(static_cast\\s*<\\s*JSObject\\s*>\\s*\\()"
  )
}

// -----------------------------
// Inline-cast-of-GetCurrent: JSObject::cast(iter.GetCurrent<JSObject>()) 등
// -----------------------------
predicate isInlineCastOfGetCurrent(Call c) {
  c.toString().regexpMatch(
    "JSObject::cast\\s*\\(.*GetCurrent\\s*<\\s*JSObject\\s*>\\s*\\)|Handle\\s*<\\s*JSObject\\s*>\\s*::\\s*cast\\s*\\(.*GetCurrent\\s*<\\s*JSObject\\s*>\\s*\\)|static_cast\\s*<\\s*JSObject\\s*>\\s*\\(.*GetCurrent\\s*<\\s*JSObject\\s*>\\s*\\)"
  )
}

// -----------------------------
// Broad inline pattern: JSObject::cast(...) whose argument text contains GetCurrent<JSObject>
// (이 케이스는 Call이면서도 inline-cast 패턴이므로 별도 탐지)
// -----------------------------
predicate isCastCallWithGetCurrentArg(Call c) {
  c.toString().regexpMatch("JSObject::cast\\s*\\(.*GetCurrent\\s*<\\s*JSObject\\s*>.*\\)")
}

// -----------------------------
// Single unified query: 모든 케이스를 OR로 묶어 하나의 select로 리턴
// - 반환: Call 노드와 kind (어떤 후보인지 설명)
// -----------------------------
from Call c, Function f, string kind
where
  (
    // case A: GetCurrent-like call, and enclosing function lacks obvious guard(s)
    isGetCurrentLikeCall(c)
    and f = c.getEnclosingFunction()
    and not exists(Stmt g | g.getEnclosingFunction() = f and hasGuardText(g))
    and kind = "GetCurrent-like call WITHOUT obvious IsJSObject/IsWasmObject/IsJSProxy guard (heuristic)"
  )
  or
  (
    // case B: GetCurrent-like call (broad), even if there is a guard (so reviewer can inspect)
    isGetCurrentLikeCall(c)
    and kind = "GetCurrent-like call (candidate)"
  )
  or
  (
    // case C: direct JSObject cast calls
    isDirectJSObjectCast(c)
    and kind = "Direct cast to JSObject (JSObject::cast / Handle<JSObject>::cast / static_cast<JSObject>)"
  )
  or
  (
    // case D: inline cast of GetCurrent result (e.g., JSObject::cast(iter.GetCurrent<JSObject>()))
    isInlineCastOfGetCurrent(c)
    and kind = "Inline cast of GetCurrent<JSObject>() result"
  )
  or
  (
    // case E: broader textual inline pattern (safety net)
    isCastCallWithGetCurrentArg(c)
    and kind = "Cast call whose arg contains GetCurrent<JSObject> (text match)"
  )
select c.getFile().getRelativePath(), c.getLocation().getStartLine()