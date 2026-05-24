# Softanza Engine -- Pattern Detection
#
# Loads stz_pattern.dll for palindrome/repeat/sequence/prefix/suffix.
#
# Function prefix: StzEnginePattern*

if isWindows()
    $cStzPatternLib = $cEngineDir + "/zig-out/bin/stz_pattern.dll"
but isLinux()
    $cStzPatternLib = $cEngineDir + "/zig-out/lib/libstz_pattern.so"
but isMacOS()
    $cStzPatternLib = $cEngineDir + "/zig-out/lib/libstz_pattern.dylib"
ok

if fexists($cStzPatternLib)
    $pStzPatternHandle = LoadLib($cStzPatternLib)
else
    ? "WARNING: stz_pattern not found at: " + $cStzPatternLib
    $pStzPatternHandle = NULL
ok
