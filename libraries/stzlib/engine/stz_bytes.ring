# Softanza Engine -- Base Bytes FFI Bridge
#
# Loads stz_bytes.dll -- byte array operations.
# Used by: base/number/stzListOfBytes.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzBytesLib = currentdir() + "/zig-out/bin/stz_bytes.dll"
but isLinux()
    $cStzBytesLib = currentdir() + "/zig-out/lib/libstz_bytes.so"
but isMacOS()
    $cStzBytesLib = currentdir() + "/zig-out/lib/libstz_bytes.dylib"
ok

if fexists($cStzBytesLib)
    $pStzBytesHandle = LoadLib($cStzBytesLib)
else
    ? "WARNING: stz_bytes not found at: " + $cStzBytesLib
    $pStzBytesHandle = NULL
ok

func StzEngineBytesNew()
    if $pStzBytesHandle = NULL return NULL ok
    return CallCFunc($pStzBytesHandle, "stz_bytes_new", "p", "")

func StzEngineBytesFrom(cData)
    if $pStzBytesHandle = NULL return NULL ok
    return CallCFunc($pStzBytesHandle, "stz_bytes_from", "p", "pi", cData, len(cData))

func StzEngineBytesFree(pHandle)
    if $pStzBytesHandle = NULL return ok
    CallCFunc($pStzBytesHandle, "stz_bytes_free", "v", "p", pHandle)

func StzEngineBytesSize(pHandle)
    if $pStzBytesHandle = NULL return 0 ok
    return CallCFunc($pStzBytesHandle, "stz_bytes_size", "i", "p", pHandle)

func StzEngineBytesIsEmpty(pHandle)
    if $pStzBytesHandle = NULL return 1 ok
    return CallCFunc($pStzBytesHandle, "stz_bytes_is_empty", "i", "p", pHandle)

func StzEngineBytesClear(pHandle)
    if $pStzBytesHandle = NULL return ok
    CallCFunc($pStzBytesHandle, "stz_bytes_clear", "v", "p", pHandle)

func StzEngineBytesAppend(pHandle, cData)
    if $pStzBytesHandle = NULL return ok
    CallCFunc($pStzBytesHandle, "stz_bytes_append", "v", "ppi", pHandle, cData, len(cData))

func StzEngineBytesAt(pHandle, nIndex)
    if $pStzBytesHandle = NULL return -1 ok
    return CallCFunc($pStzBytesHandle, "stz_bytes_at", "i", "pi", pHandle, nIndex)

func StzEngineBytesLeft(pHandle, n)
    if $pStzBytesHandle = NULL return "" ok
    cBuf = space(n)
    nLen = CallCFunc($pStzBytesHandle, "stz_bytes_left", "i", "pipi", pHandle, n, cBuf, n)
    return left(cBuf, nLen)

func StzEngineBytesRight(pHandle, n)
    if $pStzBytesHandle = NULL return "" ok
    cBuf = space(n)
    nLen = CallCFunc($pStzBytesHandle, "stz_bytes_right", "i", "pipi", pHandle, n, cBuf, n)
    return left(cBuf, nLen)

func StzEngineBytesMid(pHandle, nPos, nCount)
    if $pStzBytesHandle = NULL return "" ok
    cBuf = space(nCount)
    nLen = CallCFunc($pStzBytesHandle, "stz_bytes_mid", "i", "piipi",
                     pHandle, nPos, nCount, cBuf, nCount)
    return left(cBuf, nLen)

func StzEngineBytesFill(pHandle, nVal, nCount)
    if $pStzBytesHandle = NULL return ok
    CallCFunc($pStzBytesHandle, "stz_bytes_fill", "v", "pii", pHandle, nVal, nCount)

func StzEngineBytesResize(pHandle, n)
    if $pStzBytesHandle = NULL return ok
    CallCFunc($pStzBytesHandle, "stz_bytes_resize", "v", "pi", pHandle, n)

func StzEngineBytesToBase64(pHandle)
    if $pStzBytesHandle = NULL return "" ok
    cBuf = space(65536)
    nLen = CallCFunc($pStzBytesHandle, "stz_bytes_to_base64", "i", "ppi", pHandle, cBuf, 65536)
    return left(cBuf, nLen)

func StzEngineBytesFromBase64(pHandle, cEncoded)
    if $pStzBytesHandle = NULL return 0 ok
    return CallCFunc($pStzBytesHandle, "stz_bytes_from_base64", "i", "ppi",
                     pHandle, cEncoded, len(cEncoded))

func StzEngineBytesToHex(pHandle)
    if $pStzBytesHandle = NULL return "" ok
    cBuf = space(131072)
    nLen = CallCFunc($pStzBytesHandle, "stz_bytes_to_hex", "i", "ppi", pHandle, cBuf, 131072)
    return left(cBuf, nLen)

func StzEngineBytesFromHex(pHandle, cHex)
    if $pStzBytesHandle = NULL return 0 ok
    return CallCFunc($pStzBytesHandle, "stz_bytes_from_hex", "i", "ppi",
                     pHandle, cHex, len(cHex))

func StzEngineBytesToPercent(pHandle)
    if $pStzBytesHandle = NULL return "" ok
    cBuf = space(196608)
    nLen = CallCFunc($pStzBytesHandle, "stz_bytes_to_percent", "i", "ppi", pHandle, cBuf, 196608)
    return left(cBuf, nLen)

func StzEngineBytesFromPercent(pHandle, cEncoded)
    if $pStzBytesHandle = NULL return 0 ok
    return CallCFunc($pStzBytesHandle, "stz_bytes_from_percent", "i", "ppi",
                     pHandle, cEncoded, len(cEncoded))

func StzEngineBytesToLower(pHandle)
    if $pStzBytesHandle = NULL return "" ok
    nSize = StzEngineBytesSize(pHandle)
    if nSize = 0 return "" ok
    cBuf = space(nSize)
    nLen = CallCFunc($pStzBytesHandle, "stz_bytes_to_lower", "i", "ppi", pHandle, cBuf, nSize)
    return left(cBuf, nLen)

func StzEngineBytesToUpper(pHandle)
    if $pStzBytesHandle = NULL return "" ok
    nSize = StzEngineBytesSize(pHandle)
    if nSize = 0 return "" ok
    cBuf = space(nSize)
    nLen = CallCFunc($pStzBytesHandle, "stz_bytes_to_upper", "i", "ppi", pHandle, cBuf, nSize)
    return left(cBuf, nLen)
