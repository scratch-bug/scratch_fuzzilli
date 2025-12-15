import cpp

/** Detects function calls that allow subtype checks (e.g., IsCanonicalSubtype, IsSubtype, IsAssignableFrom) */
predicate usesSubtypeCheck(Call c) {
  exists(Function tf |
    c.getTarget() = tf and
    (
      tf.getName().regexpMatch("(?i)(Is.*Subtype|IsSubtype|IsCanonicalSubtype|IsAssignable(From)?)") or
      tf.getQualifiedName().regexpMatch("(?i)(Is.*Subtype|IsSubtype|IsCanonicalSubtype|IsAssignable(From)?)")
    )
  )
  or c.toString().regexpMatch("(?i)type_canonicalizer\\s*\\(\\)\\s*->\\s*IsCanonicalSubtype")
  or c.toString().regexpMatch("(?i)\\bIs(Canonical)?Subtype\\s*\\(")
  or c.toString().regexpMatch("(?i)\\bIsAssignable(From)?\\s*\\(")
}

/** Identifies functions likely related to link/import logic */
predicate looksLikeLinkOrImportContext(Function f) {
  f.getName().regexpMatch("(?i)(ProcessImports|ResolveImports|Link|Linker|Instantiate|AddImport|ProcessImport)")
  or f.getQualifiedName().regexpMatch("(?i)(InstanceBuilder|Module.*Link|.*::ProcessImports|.*::ResolveImports)")
  or exists(Stmt s |
    s.getEnclosingFunction() = f and
    s.toString().regexpMatch("(?i)import|link|instantiate|resolver|builder")
  )
}

/** Detects mentions of mutable entities such as tags, exceptions, structs, or fields */
predicate mentionsMutableEntity(Function f) {
  exists(Stmt s |
    s.getEnclosingFunction() = f and
    s.toString().regexpMatch("(?i)(WasmTag(Object)?|exception|tag(s)?_table|exception(s)?_table|structs?|fields?_table|fields?\\s*\\[|set\\s*\\(|assign|store)")
  )
}

/** Checks for absence of an explicit equality guard (canonical == expected …) */
predicate lacksExactEqualityGuard(Function f) {
  not exists(Stmt s |
    s.getEnclosingFunction() = f and
    s.toString().regexpMatch("(?i)(canonical|expected|type(_|\\s*)id|signature).{0,40}==")
  )
}

/**
 * Main rule:
 * Finds subtype-accepting checks inside link/import contexts that manipulate mutable entities
 * (tags, exceptions, structs, fields) without enforcing exact signature equality.
 */
from Call c, Function f
where usesSubtypeCheck(c)
  and c.getEnclosingFunction() = f
  and looksLikeLinkOrImportContext(f)
  and mentionsMutableEntity(f)
  and lacksExactEqualityGuard(f)
select c.getFile().getRelativePath(), c.getLocation().getStartLine()