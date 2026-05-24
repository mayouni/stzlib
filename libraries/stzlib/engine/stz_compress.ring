# Softanza Engine -- Compression Utilities
#
# Loads stz_compress.dll for deflate/inflate, CRC-32, Adler-32, RLE.
#
# Function prefix: StzEngineCompress*

if isWindows()
    $cStzCompressLib = $cEngineDir + "/zig-out/bin/stz_compress.dll"
but isLinux()
    $cStzCompressLib = $cEngineDir + "/zig-out/lib/libstz_compress.so"
but isMacOS()
    $cStzCompressLib = $cEngineDir + "/zig-out/lib/libstz_compress.dylib"
ok

if fexists($cStzCompressLib)
    $pStzCompressHandle = LoadLib($cStzCompressLib)
else
    ? "WARNING: stz_compress not found at: " + $cStzCompressLib
    $pStzCompressHandle = NULL
ok
