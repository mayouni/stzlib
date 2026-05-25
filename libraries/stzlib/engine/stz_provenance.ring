# Softanza Engine -- Provenance Tracking
#
# Loads stz_provenance.dll for provenance tracking.
#
# Function prefix: StzEngineProvenance*

if isWindows()
    $cStzProvenanceLib = $cEngineDir + "/zig-out/bin/stz_provenance.dll"
but isLinux()
    $cStzProvenanceLib = $cEngineDir + "/zig-out/lib/libstz_provenance.so"
but isMacOS()
    $cStzProvenanceLib = $cEngineDir + "/zig-out/lib/libstz_provenance.dylib"
ok
if fexists($cStzProvenanceLib)
    $pStzProvenanceHandle = LoadLib($cStzProvenanceLib)
else
    ? "WARNING: stz_provenance not found at: " + $cStzProvenanceLib
    $pStzProvenanceHandle = NULL
ok
