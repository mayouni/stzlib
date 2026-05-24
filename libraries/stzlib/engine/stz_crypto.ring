# Softanza Engine -- Cryptographic Hashing
#
# Loads stz_crypto.dll for SHA-256, MD5, CRC-32, FNV hashing.
#
# Function prefix: StzEngineCrypto*

if isWindows()
    $cStzCryptoLib = $cEngineDir + "/zig-out/bin/stz_crypto.dll"
but isLinux()
    $cStzCryptoLib = $cEngineDir + "/zig-out/lib/libstz_crypto.so"
but isMacOS()
    $cStzCryptoLib = $cEngineDir + "/zig-out/lib/libstz_crypto.dylib"
ok

if fexists($cStzCryptoLib)
    $pStzCryptoHandle = LoadLib($cStzCryptoLib)
else
    ? "WARNING: stz_crypto not found at: " + $cStzCryptoLib
    $pStzCryptoHandle = NULL
ok
