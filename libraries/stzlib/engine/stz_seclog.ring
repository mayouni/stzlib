# Softanza Engine -- Security Event Ledger (incident I1)
#
# Loads stz_seclog.dll: the bounded, hash-chained ledger of security
# events. Evidence, not logging -- each entry's digest includes the
# previous one, so a retroactive edit breaks the chain and Verify()
# names the first broken link.
#
# Function prefix: StzEngineSecLog*

if isWindows()
    $cStzSecLogLib = $cEngineDir + "/zig-out/bin/stz_seclog.dll"
but isLinux()
    $cStzSecLogLib = $cEngineDir + "/zig-out/lib/libstz_seclog.so"
but isMacOS()
    $cStzSecLogLib = $cEngineDir + "/zig-out/lib/libstz_seclog.dylib"
ok

if fexists($cStzSecLogLib)
    $pStzSecLogHandle = LoadLib($cStzSecLogLib)
else
    ? "WARNING: stz_seclog not found at: " + $cStzSecLogLib
    $pStzSecLogHandle = NULL
ok
