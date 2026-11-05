# Softanza Engine -- Number Theory
#
# Loads stz_numtheory.dll for GCD/LCM/primes/factorize/fibonacci/modular.
#
# Function prefix: StzEngineNumTheory*

if isWindows()
    $cStzNumtheoryLib = $cEngineDir + "/zig-out/bin/stz_numtheory.dll"
but isLinux()
    $cStzNumtheoryLib = $cEngineDir + "/zig-out/lib/libstz_numtheory.so"
but isMacOS()
    $cStzNumtheoryLib = $cEngineDir + "/zig-out/lib/libstz_numtheory.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("numtheory")
    $pStzNumtheoryHandle = NULL
but fexists($cStzNumtheoryLib)
    $pStzNumtheoryHandle = LoadLib($cStzNumtheoryLib)
else
    ? "WARNING: stz_numtheory not found at: " + $cStzNumtheoryLib
    $pStzNumtheoryHandle = NULL
ok
