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
if fexists($cStzTestoorLib)
    $pStzTestoorHandle = LoadLib($cStzTestoorLib)
    $bStzTestoorCore = 1
else
    $pStzTestoorHandle = NULL
ok
