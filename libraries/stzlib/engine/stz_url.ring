# Softanza Engine -- Base URL FFI Bridge
#
# Loads stz_url.dll -- URL parsing.
# Used by: base/network/stzUrl.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzUrlLib = currentdir() + "/zig-out/bin/stz_url.dll"
but isLinux()
    $cStzUrlLib = currentdir() + "/zig-out/lib/libstz_url.so"
but isMacOS()
    $cStzUrlLib = currentdir() + "/zig-out/lib/libstz_url.dylib"
ok

if fexists($cStzUrlLib)
    $pStzUrlHandle = LoadLib($cStzUrlLib)
else
    ? "WARNING: stz_url not found at: " + $cStzUrlLib
    $pStzUrlHandle = NULL
ok

func StzEngineUrlParse(cUrl)
    if $pStzUrlHandle = NULL return NULL ok
    return CallCFunc($pStzUrlHandle, "stz_url_parse", "p", "pi", cUrl, len(cUrl))

func StzEngineUrlFree(pHandle)
    if $pStzUrlHandle = NULL return ok
    CallCFunc($pStzUrlHandle, "stz_url_free", "v", "p", pHandle)

func StzEngineUrlIsValid(pHandle)
    if $pStzUrlHandle = NULL return 0 ok
    return CallCFunc($pStzUrlHandle, "stz_url_is_valid", "i", "p", pHandle)

func StzEngineUrlScheme(pHandle)
    if $pStzUrlHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pStzUrlHandle, "stz_url_scheme", "i", "ppi", pHandle, cBuf, 32)
    return left(cBuf, nLen)

func StzEngineUrlHost(pHandle)
    if $pStzUrlHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pStzUrlHandle, "stz_url_host", "i", "ppi", pHandle, cBuf, 256)
    return left(cBuf, nLen)

func StzEngineUrlPort(pHandle)
    if $pStzUrlHandle = NULL return -1 ok
    return CallCFunc($pStzUrlHandle, "stz_url_port", "i", "p", pHandle)

func StzEngineUrlPath(pHandle)
    if $pStzUrlHandle = NULL return "" ok
    cBuf = space(4096)
    nLen = CallCFunc($pStzUrlHandle, "stz_url_path", "i", "ppi", pHandle, cBuf, 4096)
    return left(cBuf, nLen)

func StzEngineUrlQuery(pHandle)
    if $pStzUrlHandle = NULL return "" ok
    cBuf = space(4096)
    nLen = CallCFunc($pStzUrlHandle, "stz_url_query", "i", "ppi", pHandle, cBuf, 4096)
    return left(cBuf, nLen)

func StzEngineUrlFragment(pHandle)
    if $pStzUrlHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pStzUrlHandle, "stz_url_fragment", "i", "ppi", pHandle, cBuf, 256)
    return left(cBuf, nLen)

func StzEngineUrlUser(pHandle)
    if $pStzUrlHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pStzUrlHandle, "stz_url_user", "i", "ppi", pHandle, cBuf, 256)
    return left(cBuf, nLen)

func StzEngineUrlPassword(pHandle)
    if $pStzUrlHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pStzUrlHandle, "stz_url_password", "i", "ppi", pHandle, cBuf, 256)
    return left(cBuf, nLen)

func StzEngineUrlReconstruct(pHandle)
    if $pStzUrlHandle = NULL return "" ok
    cBuf = space(8192)
    nLen = CallCFunc($pStzUrlHandle, "stz_url_reconstruct", "i", "ppi", pHandle, cBuf, 8192)
    return left(cBuf, nLen)
