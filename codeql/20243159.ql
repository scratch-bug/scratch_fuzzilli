import cpp

/*
  Pattern of enum-cache initialization functions to detect.
  Modify this list if your codebase uses different naming conventions.
*/
predicate initPattern(string s) { 
  s = "InitializeFastPropertyEnumCache|FastKeyAccumulator::InitializeFastPropertyEnumCache|SetEnumCache|CopyEnumCache|ClearEnumCache"
}

/*
  Detects functions that reference "enum_cache" anywhere in their body.
*/
predicate referencesEnumCache(Function f) {
  exists(Expr e |
    e.getEnclosingFunction() = f and
    e.toString().regexpMatch("\\benum_cache\\b")
  )
}

/*
  Detects functions that call any of the enum-cache initialization functions.
  Matches both direct and qualified function names.
*/
predicate callsInitializer(Function f) {
  exists(Call c, string pat |
    initPattern(pat) and
    c.getEnclosingFunction() = f and
    (
      exists(Function tgt |
        c.getTarget() = tgt and
        (
          tgt.getQualifiedName().regexpMatch(pat) or
          tgt.getName().regexpMatch(pat)
        )
      )
      or
      c.toString().regexpMatch(pat)
    )
  )
}

/*
  Detects the presence of guards that verify enum_cache length or related
  conditions. These include:
    - Checking enum_cache()->keys()->length() > 0 (or similar forms)
    - Use of had_any_enum_cache flag
    - Expressions that mention both split_map and enum_cache
    - Comparisons involving NumberOfEnumerableProperties()
*/
predicate hasGuard(Function f) {
  exists(Expr e |
    e.getEnclosingFunction() = f and
    e.toString().regexpMatch(
      "("
        // enum_cache length comparison (supports -> or .)
        + "enum_cache\\b.*keys\\s*\\(\\)\\s*(?:->|\\.)\\s*length\\s*\\(\\)\\s*[!<>=]=?\\s*0"
      + ")|("
        // use of had_any_enum_cache variable
        + "\\bhad_any_enum_cache\\b"
      + ")|("
        // mentions both split_map and enum_cache (likely guard context)
        + "\\bsplit_map\\b.*enum_cache\\b"
      + ")|("
        // comparison involving NumberOfEnumerableProperties()
        + "NumberOfEnumerableProperties\\s*\\(\\)\\s*[!<>=]=?\\s*0"
      + ")"
    )
  )
}

/*
  Main query:
  - Finds functions that reference enum_cache
  - Call one of the initialization/copy functions
  - But do not have any explicit guard expressions (length checks or flag use)
*/
from Function f, Call initCall, string pat
where
  initPattern(pat) and
  referencesEnumCache(f) and
  callsInitializer(f) and
  not hasGuard(f) and
  initCall.getEnclosingFunction() = f and
  (
    exists(Function tgt2 |
      initCall.getTarget() = tgt2 and
      (tgt2.getQualifiedName().regexpMatch(pat) or tgt2.getName().regexpMatch(pat))
    )
    or
    initCall.toString().regexpMatch(pat)
  )
select initCall.getFile().getRelativePath(), initCall.getLocation().getStartLine()