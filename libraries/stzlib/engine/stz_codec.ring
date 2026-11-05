# Softanza Engine -- Codec Operations
#
# Loads stz_codec.dll for Base64, Hex, URL encoding/decoding, ROT13.
#
# Function prefix: StzEngineCodec*

if isWindows()
    $cStzCodecLib = $cEngineDir + "/zig-out/bin/stz_codec.dll"
but isLinux()
    $cStzCodecLib = $cEngineDir + "/zig-out/lib/libstz_codec.so"
but isMacOS()
    $cStzCodecLib = $cEngineDir + "/zig-out/lib/libstz_codec.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("codec")
    $pStzCodecHandle = NULL
but fexists($cStzCodecLib)
    $pStzCodecHandle = LoadLib($cStzCodecLib)
else
    ? "WARNING: stz_codec not found at: " + $cStzCodecLib
    $pStzCodecHandle = NULL
ok
