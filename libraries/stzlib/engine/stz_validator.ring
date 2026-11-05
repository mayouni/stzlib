# Softanza Engine -- Validation Rules
#
# Loads stz_validator.dll for validation rules.
#
# Function prefix: StzEngineValidator*

if isWindows()
    $cStzValidatorLib = $cEngineDir + "/zig-out/bin/stz_validator.dll"
but isLinux()
    $cStzValidatorLib = $cEngineDir + "/zig-out/lib/libstz_validator.so"
but isMacOS()
    $cStzValidatorLib = $cEngineDir + "/zig-out/lib/libstz_validator.dylib"
ok
# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("validator")
    $pStzValidatorHandle = NULL
but fexists($cStzValidatorLib)
    $pStzValidatorHandle = LoadLib($cStzValidatorLib)
else
    ? "WARNING: stz_validator not found at: " + $cStzValidatorLib
    $pStzValidatorHandle = NULL
ok
