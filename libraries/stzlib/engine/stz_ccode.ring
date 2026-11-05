# Softanza Engine -- C Code Generation
#
# Loads stz_ccode.dll for C type names, function signatures, struct fields.
#
# Function prefix: StzEngineCCode*

if isWindows()
    $cStzCcodeLib = $cEngineDir + "/zig-out/bin/stz_ccode.dll"
but isLinux()
    $cStzCcodeLib = $cEngineDir + "/zig-out/lib/libstz_ccode.so"
but isMacOS()
    $cStzCcodeLib = $cEngineDir + "/zig-out/lib/libstz_ccode.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("ccode")
    $pStzCcodeHandle = NULL
but fexists($cStzCcodeLib)
    $pStzCcodeHandle = LoadLib($cStzCcodeLib)
else
    ? "WARNING: stz_ccode not found at: " + $cStzCcodeLib
    $pStzCcodeHandle = NULL
ok
