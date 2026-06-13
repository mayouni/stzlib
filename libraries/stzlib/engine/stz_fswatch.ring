# Softanza Engine -- background folder watcher (libuv-free).
#
# Loads stz_fswatch.dll. Replaces the libuv fs_event surface.
# Backed by a Zig worker thread that polls std.fs at 250ms,
# diffs against the previous snapshot, and queues ADD / MOD / DEL
# events for the Ring side to drain.
#
# Function prefix: StzEngineFsWatch*
#   StzEngineFsWatchStart(cPath)        -> opaque watcher handle
#   StzEngineFsWatchPoll(pWatch)        -> "KIND\tname\n..."
#   StzEngineFsWatchStop(pWatch)
#   StzEngineFsWatchLastError()

if isWindows()
    $cStzFsWatchLib = $cEngineDir + "/zig-out/bin/stz_fswatch.dll"
but isLinux()
    $cStzFsWatchLib = $cEngineDir + "/zig-out/lib/libstz_fswatch.so"
but isMacOS()
    $cStzFsWatchLib = $cEngineDir + "/zig-out/lib/libstz_fswatch.dylib"
ok

if fexists($cStzFsWatchLib)
    $pStzFsWatchHandle = LoadLib($cStzFsWatchLib)
else
    ? "WARNING: stz_fswatch not found at: " + $cStzFsWatchLib
    $pStzFsWatchHandle = NULL
ok
