/**
 * @name Wasm args vector used without args.size() guard
 * @description Finds V8 src/wasm code where a local 'args' vector is used as
 *              call inputs but no SBXCHECK/CHECK/DCHECK on args.size() exists
 *              in the same function.
 * @kind problem
 * @id cpp/v8/wasm-args-without-size-guard
 * @tags security
 */

import cpp

predicate inWasmFile(File f) {
  f.getRelativePath().matches("%src/wasm/%")
}

predicate isArgsVector(LocalVariable v) {
  // Local variable named `args` that is a vector-like container
  v.getName() = "args" and
  (
    v.getType().toString().matches("%SmallVector%") or
    v.getType().toString().matches("%Vector%") or
    v.getType().toString().matches("%std::vector%")
  )
}

predicate isCallInputUse(FunctionCall c) {
  // Pattern (a): base::VectorOf(args)
  c.getAnArgument().toString().regexpMatch(".*VectorOf\\s*\\(\\s*args\\s*\\).*")
  or
  // Pattern (b): AddArgumentNodes(... args ...)
  c.getTarget().getQualifiedName().regexpMatch(".*AddArgumentNodes.*") and
  c.getAnArgument().toString().regexpMatch(".*args.*")
  or
  // Pattern (c): args used as part of low-level Call*/CallBuiltin*/CallJSFunction* construction
  c.getTarget().getQualifiedName().regexpMatch(".*Call.*") and
  c.getAnArgument().toString().regexpMatch(".*args.*")
}

predicate isArgsSizeGuard(FunctionCall g) {
  // Any CHECK/SBXCHECK/DCHECK that explicitly checks args.size()
  g.getTarget().getQualifiedName().regexpMatch(".*(SBXCHECK|CHECK|DCHECK).*") and
  g.getAnArgument().toString().regexpMatch(".*args\\.size\\s*\\(\\s*\\).*")
}

from Function f, LocalVariable argsVar, VariableAccess argsAcc, FunctionCall useCall
where
  // File must be under src/wasm
  inWasmFile(f.getFile()) and

  // The function declares a local `args` vector
  argsVar.getFile() = f.getFile() and
  isArgsVector(argsVar) and

  // There exists an access to this `args` variable inside the same function
  argsAcc.getTarget() = argsVar and
  argsAcc.getEnclosingFunction() = f and

  // The `args` vector is used as call-input construction
  useCall.getEnclosingFunction() = f and
  isCallInputUse(useCall) and

  // And there is no args.size() guard inside the same function
  not exists(FunctionCall g |
    g.getEnclosingFunction() = f and
    isArgsSizeGuard(g)
  )

select useCall.getFile().getRelativePath(), useCall.getLocation().getStartLine()