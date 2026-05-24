# Softanza Engine -- Arithmetic Expression Evaluator
#
# Loads stz_arith.dll for arithmetic expression parsing/evaluation.
#
# Function prefix: StzEngineArith*

if isWindows()
    $cStzArithLib = $cEngineDir + "/zig-out/bin/stz_arith.dll"
but isLinux()
    $cStzArithLib = $cEngineDir + "/zig-out/lib/libstz_arith.so"
but isMacOS()
    $cStzArithLib = $cEngineDir + "/zig-out/lib/libstz_arith.dylib"
ok

if fexists($cStzArithLib)
    $pStzArithHandle = LoadLib($cStzArithLib)
else
    ? "WARNING: stz_arith not found at: " + $cStzArithLib
    $pStzArithHandle = NULL
ok
