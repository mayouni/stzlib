# Softanza Engine -- Base JSON FFI Bridge
#
# Loads stz_json.dll -- JSON parsing via Zig std.json.
# Used by: base/file/stzJson.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzJsonLib = $cEngineDir + "/zig-out/bin/stz_json.dll"
but isLinux()
    $cStzJsonLib = $cEngineDir + "/zig-out/lib/libstz_json.so"
but isMacOS()
    $cStzJsonLib = $cEngineDir + "/zig-out/lib/libstz_json.dylib"
ok

if fexists($cStzJsonLib)
    $pStzJsonHandle = LoadLib($cStzJsonLib)
else
    ? "WARNING: stz_json not found at: " + $cStzJsonLib
    $pStzJsonHandle = NULL
ok

func StzEngineJsonParse(cJson)
    if $pStzJsonHandle = NULL return NULL ok
    return CallCFunc($pStzJsonHandle, "stz_json_parse", "p", "pi", cJson, len(cJson))

func StzEngineJsonFree(pHandle)
    if $pStzJsonHandle = NULL return ok
    CallCFunc($pStzJsonHandle, "stz_json_free", "v", "p", pHandle)

func StzEngineJsonIsValid(pHandle)
    if $pStzJsonHandle = NULL return 0 ok
    return CallCFunc($pStzJsonHandle, "stz_json_is_valid", "i", "p", pHandle)

func StzEngineJsonIsArray(pHandle)
    if $pStzJsonHandle = NULL return 0 ok
    return CallCFunc($pStzJsonHandle, "stz_json_is_array", "i", "p", pHandle)

func StzEngineJsonSize(pHandle)
    if $pStzJsonHandle = NULL return 0 ok
    return CallCFunc($pStzJsonHandle, "stz_json_size", "i", "p", pHandle)

func StzEngineJsonHasKey(pHandle, cKey)
    if $pStzJsonHandle = NULL return 0 ok
    return CallCFunc($pStzJsonHandle, "stz_json_has_key", "i", "ppi",
                     pHandle, cKey, len(cKey))

func StzEngineJsonGetString(pHandle, cKey)
    if $pStzJsonHandle = NULL return "" ok
    cBuf = space(65536)
    nLen = CallCFunc($pStzJsonHandle, "stz_json_get_string", "i", "ppipi",
                     pHandle, cKey, len(cKey), cBuf, 65536)
    return left(cBuf, nLen)

func StzEngineJsonGetInt(pHandle, cKey)
    if $pStzJsonHandle = NULL return 0 ok
    return CallCFunc($pStzJsonHandle, "stz_json_get_int", "i", "ppi",
                     pHandle, cKey, len(cKey))

func StzEngineJsonGetBool(pHandle, cKey)
    if $pStzJsonHandle = NULL return -1 ok
    return CallCFunc($pStzJsonHandle, "stz_json_get_bool", "i", "ppi",
                     pHandle, cKey, len(cKey))

func StzEngineJsonArrayAtString(pHandle, nIndex)
    if $pStzJsonHandle = NULL return "" ok
    cBuf = space(65536)
    nLen = CallCFunc($pStzJsonHandle, "stz_json_array_at_string", "i", "pipi",
                     pHandle, nIndex, cBuf, 65536)
    return left(cBuf, nLen)

func StzEngineJsonArrayAtInt(pHandle, nIndex)
    if $pStzJsonHandle = NULL return 0 ok
    return CallCFunc($pStzJsonHandle, "stz_json_array_at_int", "i", "pi",
                     pHandle, nIndex)

func StzEngineJsonToString(pHandle)
    if $pStzJsonHandle = NULL return "" ok
    nLen = 0
    pData = CallCFunc($pStzJsonHandle, "stz_json_to_string", "p", "pp", pHandle, :nLen)
    if pData = NULL return "" ok
    cResult = copy(pData, nLen)
    CallCFunc($pStzJsonHandle, "stz_json_string_free", "v", "pi", pData, nLen)
    return cResult

func StzEngineJsonToStringPretty(pHandle)
    if $pStzJsonHandle = NULL return "" ok
    nLen = 0
    pData = CallCFunc($pStzJsonHandle, "stz_json_to_string_pretty", "p", "pp", pHandle, :nLen)
    if pData = NULL return "" ok
    cResult = copy(pData, nLen)
    CallCFunc($pStzJsonHandle, "stz_json_string_free", "v", "pi", pData, nLen)
    return cResult

func StzEngineJsonKeys(pHandle)
    if $pStzJsonHandle = NULL return [] ok
    cBuf = space(65536)
    nLen = CallCFunc($pStzJsonHandle, "stz_json_keys", "i", "ppi", pHandle, cBuf, 65536)
    if nLen = 0 return [] ok
    cKeys = left(cBuf, nLen)
    return str2list(substr(cKeys, nl, nl))

func StzEngineJsonError(pHandle)
    if $pStzJsonHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pStzJsonHandle, "stz_json_error", "i", "ppi", pHandle, cBuf, 256)
    return left(cBuf, nLen)
