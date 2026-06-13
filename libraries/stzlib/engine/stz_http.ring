# Softanza Engine -- HTTP Client (libcurl-free)
#
# Loads stz_http.dll. Replaces the libcurl.ring extension dependency
# for stzNetwork / stzHttpClient. Backed by Zig std.http.Client +
# std.crypto.tls -- HTTPS works without an external TLS lib.
#
# Function prefix: StzEngineHttp*
#   StzEngineHttpGet(cUrl)                        -> body string
#   StzEngineHttpGetStatus(cUrl)                  -> HTTP status int
#   StzEngineHttpPost(cUrl, cContentType, cBody)  -> body string
#   StzEngineHttpLastError()                      -> last error message

if isWindows()
    $cStzHttpLib = $cEngineDir + "/zig-out/bin/stz_http.dll"
but isLinux()
    $cStzHttpLib = $cEngineDir + "/zig-out/lib/libstz_http.so"
but isMacOS()
    $cStzHttpLib = $cEngineDir + "/zig-out/lib/libstz_http.dylib"
ok

if fexists($cStzHttpLib)
    $pStzHttpHandle = LoadLib($cStzHttpLib)
else
    ? "WARNING: stz_http not found at: " + $cStzHttpLib
    $pStzHttpHandle = NULL
ok
