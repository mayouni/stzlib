# Softanza Engine -- the image plane's core (IM0), SOFTANZA_IMAGE_INTELLIGENCE.md.
#
# Loads stz_image.dll: one image type (1, 3 or 4 channels of u8), gen-keyed
# handles, PNG/BMP out, stb_image in, and the first classical operations.
# stzImage and stzImageGrid (base/image/) are the faces over it.
#
# Function prefix: StzEngineImage*  -- coordinates, rows, columns and channels
# are 1-based; channel 0 is the BT.601 gray. A refused call answers 0 and
# StzEngineImageLastError() says why.

if isWindows()
    $cStzImageLib = $cEngineDir + "/zig-out/bin/stz_image.dll"
but isLinux()
    $cStzImageLib = $cEngineDir + "/zig-out/lib/libstz_image.so"
but isMacOS()
    $cStzImageLib = $cEngineDir + "/zig-out/lib/libstz_image.dylib"
ok

if fexists($cStzImageLib)
    $pStzImageHandle = LoadLib($cStzImageLib)
else
    ? "WARNING: stz_image not found at: " + $cStzImageLib
    $pStzImageHandle = NULL
ok
