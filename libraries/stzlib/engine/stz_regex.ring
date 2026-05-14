# Softanza Engine -- Base Regex FFI Bridge
#
# Loads stz_regex.dll -- pattern matching engine.
# Used by: base/regex/stzRegex.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzRegexLib = currentdir() + "/zig-out/bin/stz_regex.dll"
but isLinux()
    $cStzRegexLib = currentdir() + "/zig-out/lib/libstz_regex.so"
but isMacOS()
    $cStzRegexLib = currentdir() + "/zig-out/lib/libstz_regex.dylib"
ok

if fexists($cStzRegexLib)
    $pStzRegexHandle = LoadLib($cStzRegexLib)
else
    ? "WARNING: stz_regex not found at: " + $cStzRegexLib
    $pStzRegexHandle = NULL
ok

# Flags: 1=CaseInsensitive 2=DotMatchesAll 4=MultiLine

func StzEngineRegexNew(cPattern, nFlags)
    if $pStzRegexHandle = NULL return NULL ok
    return CallCFunc($pStzRegexHandle, "stz_regex_new", "p", "pii",
                     cPattern, len(cPattern), nFlags)

func StzEngineRegexFree(pHandle)
    if $pStzRegexHandle = NULL return ok
    CallCFunc($pStzRegexHandle, "stz_regex_free", "v", "p", pHandle)

func StzEngineRegexMatch(pHandle, cInput, nStart)
    if $pStzRegexHandle = NULL return 0 ok
    return CallCFunc($pStzRegexHandle, "stz_regex_match", "i", "ppii",
                     pHandle, cInput, len(cInput), nStart)

func StzEngineRegexMatchAll(pHandle, cInput)
    if $pStzRegexHandle = NULL return 0 ok
    return CallCFunc($pStzRegexHandle, "stz_regex_match_all", "i", "ppi",
                     pHandle, cInput, len(cInput))

func StzEngineRegexHasMatch(pHandle)
    if $pStzRegexHandle = NULL return 0 ok
    return CallCFunc($pStzRegexHandle, "stz_regex_has_match", "i", "p", pHandle)

func StzEngineRegexCaptureCount(pHandle)
    if $pStzRegexHandle = NULL return 0 ok
    return CallCFunc($pStzRegexHandle, "stz_regex_capture_count", "i", "p", pHandle)

func StzEngineRegexCaptureStart(pHandle, nIndex)
    if $pStzRegexHandle = NULL return -1 ok
    return CallCFunc($pStzRegexHandle, "stz_regex_capture_start", "i", "pi",
                     pHandle, nIndex)

func StzEngineRegexCaptureEnd(pHandle, nIndex)
    if $pStzRegexHandle = NULL return -1 ok
    return CallCFunc($pStzRegexHandle, "stz_regex_capture_end", "i", "pi",
                     pHandle, nIndex)

func StzEngineRegexCaptureText(pHandle, nIndex)
    if $pStzRegexHandle = NULL return "" ok
    cBuf = space(4096)
    nLen = CallCFunc($pStzRegexHandle, "stz_regex_capture_text", "i", "pipi",
                     pHandle, nIndex, cBuf, 4096)
    return left(cBuf, nLen)

func StzEngineRegexReplace(pHandle, cInput, cReplacement)
    if $pStzRegexHandle = NULL return cInput ok
    nLen = 0
    pData = CallCFunc($pStzRegexHandle, "stz_regex_replace", "p", "ppipip",
                      pHandle, cInput, len(cInput), cReplacement, len(cReplacement), :nLen)
    if pData = NULL return cInput ok
    cResult = copy(pData, nLen)
    CallCFunc($pStzRegexHandle, "stz_regex_replace_free", "v", "pi", pData, nLen)
    return cResult
