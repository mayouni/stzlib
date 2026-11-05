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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("reactor")
    $pStzReactorHandle = NULL
but fexists($cStzReactorLib)
    $pStzReactorHandle = LoadLib($cStzReactorLib)
else
    ? "WARNING: stz_reactor not found at: " + $cStzReactorLib
    $pStzReactorHandle = NULL
ok
