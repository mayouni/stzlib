# Softanza Engine -- WebSocket client (RFC 6455) and a loopback echo server.
#
# Loads stz_ws.dll. Framing, handshake, masking, UTF-8 and size checks, the
# close handshake and TLS (mbedTLS, verified) all run in the engine
# (engine/src/ws.zig); stzWebSocket is the thin face over it.
#
# Function prefix: StzEngineWs*
#   StzEngineWsNew()                                    -> client handle
#   StzEngineWsConnect(h, cUrl)                         -> 1 ok / 0 failed
#   StzEngineWsSend(h, nOpcode, cBytes)                 -> 1 / 0  (1 text, 2 binary)
#   StzEngineWsPing(h, cBytes)                          -> 1 / 0
#   StzEngineWsRecv(h, nTimeoutMs)                      -> 0 nothing, 1 text, 2 binary, 3 pong, 4 peer closed, -1 failed
#   StzEngineWsLastPayload(h)                           -> the last message, binary-safe
#   StzEngineWsClose(h, nCode, cReason)                 -> 1 when the peer answered
#   StzEngineWsIsOpen / CloseCode / CloseReason / CloseByPeer / Subprotocol / LastError(h)
#   StzEngineWsSetMaxMessage / SetConnectTimeout / SetCloseWait / SetSubprotocols / SetHeaders / SetCaFile / SetInsecure(h, x)
#   StzEngineWsFree(h)
#   StzEngineWsEchoStart(nPort, bTls, cCertPem, cKeyPem) -> port   (test support)
#   StzEngineWsEchoStop()

if isWindows()
    $cStzWsLib = $cEngineDir + "/zig-out/bin/stz_ws.dll"
but isLinux()
    $cStzWsLib = $cEngineDir + "/zig-out/lib/libstz_ws.so"
but isMacOS()
    $cStzWsLib = $cEngineDir + "/zig-out/lib/libstz_ws.dylib"
ok

if fexists($cStzWsLib)
    $pStzWsHandle = LoadLib($cStzWsLib)
else
    ? "WARNING: stz_ws not found at: " + $cStzWsLib
    $pStzWsHandle = NULL
ok
