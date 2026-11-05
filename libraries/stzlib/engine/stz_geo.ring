# Softanza Engine -- Geographic Utilities
#
# Loads stz_geo.dll for haversine, bearing, midpoint, coordinate ops.
#
# Function prefix: StzEngineGeo*

if isWindows()
    $cStzGeoLib = $cEngineDir + "/zig-out/bin/stz_geo.dll"
but isLinux()
    $cStzGeoLib = $cEngineDir + "/zig-out/lib/libstz_geo.so"
but isMacOS()
    $cStzGeoLib = $cEngineDir + "/zig-out/lib/libstz_geo.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("geo")
    $pStzGeoHandle = NULL
but fexists($cStzGeoLib)
    $pStzGeoHandle = LoadLib($cStzGeoLib)
else
    ? "WARNING: stz_geo not found at: " + $cStzGeoLib
    $pStzGeoHandle = NULL
ok
