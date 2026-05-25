# Softanza Engine -- Topology Engine
#
# Loads stz_topology.dll for topology engine.
#
# Function prefix: StzEngineTopology*

if isWindows()
    $cStzTopologyLib = $cEngineDir + "/zig-out/bin/stz_topology.dll"
but isLinux()
    $cStzTopologyLib = $cEngineDir + "/zig-out/lib/libstz_topology.so"
but isMacOS()
    $cStzTopologyLib = $cEngineDir + "/zig-out/lib/libstz_topology.dylib"
ok
if fexists($cStzTopologyLib)
    $pStzTopologyHandle = LoadLib($cStzTopologyLib)
else
    ? "WARNING: stz_topology not found at: " + $cStzTopologyLib
    $pStzTopologyHandle = NULL
ok
