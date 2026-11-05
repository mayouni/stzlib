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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("pattern")
    $pStzPatternHandle = NULL
but fexists($cStzPatternLib)
    $pStzPatternHandle = LoadLib($cStzPatternLib)
else
    ? "WARNING: stz_pattern not found at: " + $cStzPatternLib
    $pStzPatternHandle = NULL
ok
