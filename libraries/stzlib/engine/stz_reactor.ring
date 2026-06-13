# Softanza Engine -- reactor (libuv-backed async I/O backbone).
#
# Loads stz_reactor.dll, which statically links vendored libuv
# (engine/vendor/libuv). Tier 2 foundation: epoll/kqueue/IOCP behind
# libuv's one proactor API.
#
# Function prefix: StzEngineReactor*
#   StzEngineReactorVersion()   -> libuv version string (e.g. "1.52.1")
#   StzEngineReactorSelfTest()  -> timer callbacks fired (1 = loop OK)

if isWindows()
    $cStzReactorLib = $cEngineDir + "/zig-out/bin/stz_reactor.dll"
but isLinux()
    $cStzReactorLib = $cEngineDir + "/zig-out/lib/libstz_reactor.so"
but isMacOS()
    $cStzReactorLib = $cEngineDir + "/zig-out/lib/libstz_reactor.dylib"
ok

if fexists($cStzReactorLib)
    $pStzReactorHandle = LoadLib($cStzReactorLib)
else
    ? "WARNING: stz_reactor not found at: " + $cStzReactorLib
    $pStzReactorHandle = NULL
ok
