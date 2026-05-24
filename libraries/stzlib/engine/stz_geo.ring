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

if fexists($cStzGeoLib)
    $pStzGeoHandle = LoadLib($cStzGeoLib)
else
    ? "WARNING: stz_geo not found at: " + $cStzGeoLib
    $pStzGeoHandle = NULL
ok
