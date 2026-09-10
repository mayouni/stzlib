# Softanza Engine -- Stats Ring Bridge
#
# Loads stz_stats.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineStats*

if isWindows()
    $cStzStatsLib = $cEngineDir + "/zig-out/bin/stz_stats.dll"
but isLinux()
    $cStzStatsLib = $cEngineDir + "/zig-out/lib/libstz_stats.so"
but isMacOS()
    $cStzStatsLib = $cEngineDir + "/zig-out/lib/libstz_stats.dylib"
ok

if fexists($cStzStatsLib)
    $pStzStatsHandle = LoadLib($cStzStatsLib)
    # GS6a: t-SNE epochs can run on the GPU -- record WHERE the wgpu runtime
    # lives; the device is opened lazily at the first eligible fit, and a
    # machine without a GPU (or the runtime) stays silently on the CPU
    StzEngineTsneGpuRuntimePath($cEngineDir + "/zig-out/bin/wgpu_native.dll")
else
    ? "WARNING: stz_stats not found at: " + $cStzStatsLib
    $pStzStatsHandle = NULL
ok
