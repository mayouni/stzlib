# Softanza Engine -- TCP Client + Server (libuv-free)
#
# Loads stz_tcp.dll. Replaces the libuv-based stzTcp* surface.
# Backed by Zig std.net -- synchronous (blocking) operations.
#
# Function prefix: StzEngineTcp*
#   StzEngineTcpConnect(cHost, nPort)              -> client handle
#   StzEngineTcpSend(pClient, cData)               -> bytes sent
#   StzEngineTcpRecv(pClient, nMaxBytes)           -> received string
#   StzEngineTcpClose(pClient)
#   StzEngineTcpListen(cHost, nPort)               -> server handle
#   StzEngineTcpAccept(pServer)                    -> client handle
#   StzEngineTcpServerClose(pServer)
#   StzEngineTcpLastError()                        -> last error message

if isWindows()
    $cStzTcpLib = $cEngineDir + "/zig-out/bin/stz_tcp.dll"
but isLinux()
    $cStzTcpLib = $cEngineDir + "/zig-out/lib/libstz_tcp.so"
but isMacOS()
    $cStzTcpLib = $cEngineDir + "/zig-out/lib/libstz_tcp.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("tcp")
    $pStzTcpHandle = NULL
but fexists($cStzTcpLib)
    $pStzTcpHandle = LoadLib($cStzTcpLib)
else
    ? "WARNING: stz_tcp not found at: " + $cStzTcpLib
    $pStzTcpHandle = NULL
ok
