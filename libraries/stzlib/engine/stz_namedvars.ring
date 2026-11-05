# Softanza Engine -- Named Variables
#
# Loads stz_namedvars.dll for named parameter store with type tracking.
#
# Function prefix: StzEngineNamedvars*

if isWindows()
    $cStzNamedvarsLib = $cEngineDir + "/zig-out/bin/stz_namedvars.dll"
but isLinux()
    $cStzNamedvarsLib = $cEngineDir + "/zig-out/lib/libstz_namedvars.so"
but isMacOS()
    $cStzNamedvarsLib = $cEngineDir + "/zig-out/lib/libstz_namedvars.dylib"
ok
# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("namedvars")
    $pStzNamedvarsHandle = NULL
but fexists($cStzNamedvarsLib)
    $pStzNamedvarsHandle = LoadLib($cStzNamedvarsLib)
else
    ? "WARNING: stz_namedvars not found at: " + $cStzNamedvarsLib
    $pStzNamedvarsHandle = NULL
ok
