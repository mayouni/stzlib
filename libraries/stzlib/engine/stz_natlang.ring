# Softanza Engine -- Natural Language Utilities
#
# Loads stz_natlang.dll for word/sentence counting, case/content checks.
#
# Function prefix: StzEngineNatLang*

if isWindows()
    $cStzNatlangLib = $cEngineDir + "/zig-out/bin/stz_natlang.dll"
but isLinux()
    $cStzNatlangLib = $cEngineDir + "/zig-out/lib/libstz_natlang.so"
but isMacOS()
    $cStzNatlangLib = $cEngineDir + "/zig-out/lib/libstz_natlang.dylib"
ok

if fexists($cStzNatlangLib)
    $pStzNatlangHandle = LoadLib($cStzNatlangLib)
else
    ? "WARNING: stz_natlang not found at: " + $cStzNatlangLib
    $pStzNatlangHandle = NULL
ok
