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
if fexists($cStzValidatorLib)
    $pStzValidatorHandle = LoadLib($cStzValidatorLib)
else
    ? "WARNING: stz_validator not found at: " + $cStzValidatorLib
    $pStzValidatorHandle = NULL
ok
