# Softanza Engine -- loopback HTTP test server (test fixture).
#
# Loads stz_testsrv.dll. A std.net HTTP/1.1 server on 127.0.0.1 serving
# canned responses by path, for hardening the HTTP client offline (no
# public internet, deterministic). See engine/src/testserver.zig.
#
#   StzEngineTestServerStart(nPort)  -> actual bound port (0 = ephemeral)
#   StzEngineTestServerStop()

if isWindows()
    $cStzTestSrvLib = $cEngineDir + "/zig-out/bin/stz_testsrv.dll"
but isLinux()
    $cStzTestSrvLib = $cEngineDir + "/zig-out/lib/libstz_testsrv.so"
but isMacOS()
    $cStzTestSrvLib = $cEngineDir + "/zig-out/lib/libstz_testsrv.dylib"
ok

if fexists($cStzTestSrvLib)
    $pStzTestSrvHandle = LoadLib($cStzTestSrvLib)
else
    ? "WARNING: stz_testsrv not found at: " + $cStzTestSrvLib
    $pStzTestSrvHandle = NULL
ok
