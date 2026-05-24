# Softanza Engine -- Stream Operations
#
# Loads stz_stream.dll for byte stream read/write with cursor.
#
# Function prefix: StzEngineStream*

if isWindows()
    $cStzStreamLib = $cEngineDir + "/zig-out/bin/stz_stream.dll"
but isLinux()
    $cStzStreamLib = $cEngineDir + "/zig-out/lib/libstz_stream.so"
but isMacOS()
    $cStzStreamLib = $cEngineDir + "/zig-out/lib/libstz_stream.dylib"
ok

if fexists($cStzStreamLib)
    $pStzStreamHandle = LoadLib($cStzStreamLib)
else
    ? "WARNING: stz_stream not found at: " + $cStzStreamLib
    $pStzStreamHandle = NULL
ok
