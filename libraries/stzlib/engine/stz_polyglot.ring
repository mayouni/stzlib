# Softanza Engine -- polyglot code parsing (tree-sitter).
#
# Loads stz_polyglot.dll: vendored tree-sitter runtime + tree-sitter-python
# grammar (C, compiled by Zig -- NO Python/external runtime). Parses source
# to the CLASS|/METHOD|/FUNC|/IMPORT|/CALL| line protocol the code-graph
# ingests. Adding a language = another vendored grammar behind this door.
#
# Function prefix: StzEnginePolyglot*

if isWindows()
    $cStzPolyglotLib = $cEngineDir + "/zig-out/bin/stz_polyglot.dll"
but isLinux()
    $cStzPolyglotLib = $cEngineDir + "/zig-out/lib/libstz_polyglot.so"
but isMacOS()
    $cStzPolyglotLib = $cEngineDir + "/zig-out/lib/libstz_polyglot.dylib"
ok

if fexists($cStzPolyglotLib)
    $pStzPolyglotHandle = LoadLib($cStzPolyglotLib)
else
    ? "WARNING: stz_polyglot not found at: " + $cStzPolyglotLib
    $pStzPolyglotHandle = NULL
ok
