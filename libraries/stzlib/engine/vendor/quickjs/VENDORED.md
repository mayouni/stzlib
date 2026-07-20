# quickjs-ng (vendored)

- Source: https://github.com/quickjs-ng/quickjs
- Version: v0.9.0
- License: MIT (see LICENSE)

Vendored for stzBuilder's JavaScript lowering: a JS part is embedded in a small C
host that links this engine, so it compiles to a standalone native binary (and
cross-compiles / targets wasm) through the same Zig backend as C and Ring.

Subset: the runtime only. Excluded from upstream: qjs.c / qjsc.c (CLI tools),
api-test.c / ctest.c / fuzz.c / run-test262.c (tests), unicode_gen.c /
unicode_gen_def.h (build-time table generators).

Default JS build compiles: quickjs.c libregexp.c libunicode.c cutils.c libbf.c
(quickjs-libc.c is available for parts that opt into the std/os modules).
