# Testoor core loader. The engine core is optional: when the library is absent the Ring
# reference in base/testoor judges instead, and nothing else changes.

if isWindows()
    $cStzTestoorLib = $cEngineDir + "/zig-out/bin/stz_testoor.dll"
but isLinux()
    $cStzTestoorLib = $cEngineDir + "/zig-out/lib/libstz_testoor.so"
but isMacOS()
    $cStzTestoorLib = $cEngineDir + "/zig-out/lib/libstz_testoor.dylib"
ok

$bStzTestoorCore = 0
# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("testoor")
    $pStzTestoorHandle = NULL
but fexists($cStzTestoorLib)
    $pStzTestoorHandle = LoadLib($cStzTestoorLib)
    $bStzTestoorCore = 1
else
    $pStzTestoorHandle = NULL
ok
