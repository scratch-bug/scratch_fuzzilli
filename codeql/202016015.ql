/**
 * @name Weak response identity guard after CachedResource(url) without content validation
 * @description Finds patterns where a CachedResource(url) is treated as same response
 *              using only ResponseTime / ServiceWorker-like checks, with no strong
 *              content validation (hash/etag/length/mime/body) in the guard.
 * @kind problem
 * @tags security
 * @id cpp/chromium/weak-response-identity-guard
 */

import cpp

class CachedResourceCall extends FunctionCall {
  CachedResourceCall() {
    this.getTarget().getQualifiedName().regexpMatch(".*ResourceFetcher::CachedResource") and
    this.getNumberOfArguments() >= 1
  }
}

predicate isWeakIdentityCond(Expr cond) {
  cond.toString().regexpMatch(".*ResponseTime\\s*\\(\\).*") or
  cond.toString().regexpMatch(".*WasFetchedViaServiceWorker\\s*\\(\\).*") or
  cond.toString().regexpMatch(".*ResponseSource\\s*\\(\\).*ServiceWorker.*") or
  cond.toString().regexpMatch(".*FetchResponseSource.*") or
  cond.toString().regexpMatch(".*from_service_worker.*")
}

predicate hasOnlyWeakIdentityChecks(IfStmt ifs) {
  exists(Expr cond |
    cond = ifs.getCondition() and
    isWeakIdentityCond(cond)
  )
}

predicate hasStrongContentValidationInThen(IfStmt ifs) {
  exists(FunctionCall fc |
    fc.getEnclosingStmt().getParent*() = ifs.getThen() and
    (
      fc.getTarget().getName().regexpMatch(".*(Hash|Digest|ETag|ContentLength|MimeType|Body|Data|Size).*") or
      fc.toString().regexpMatch(".*(hash|digest|etag|content-length|mime|body|payload|bytes|size).*")
    )
  )
}

predicate cachedResourceUsedForGuard(IfStmt ifs, CachedResourceCall crc) {
  exists(Stmt s |
    s = crc.getEnclosingStmt() and
    s.getParent*() = ifs.getParent*()
  )
}

from IfStmt ifs, CachedResourceCall crc
where
  cachedResourceUsedForGuard(ifs, crc) and
  hasOnlyWeakIdentityChecks(ifs) and
  not hasStrongContentValidationInThen(ifs)
select ifs.getFile().getRelativePath(), ifs.getLocation().getStartLine()