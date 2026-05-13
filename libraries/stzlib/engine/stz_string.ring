# Softanza Engine -- String + Char FFI Bridge
#
# Loads stz_string.dll/.so and wraps each C function.
# Used by: core/string/stkString.ring, core/string/stkChar.ring,
#          base/string/stzString.ring

if isWindows()
    $cStzStringLib = currentdir() + "/zig-out/bin/stz_string.dll"
but isLinux()
    $cStzStringLib = currentdir() + "/zig-out/lib/libstz_string.so"
but isMacOS()
    $cStzStringLib = currentdir() + "/zig-out/lib/libstz_string.dylib"
ok

if fexists($cStzStringLib)
    $pStzStringHandle = LoadLib($cStzStringLib)
else
    ? "WARNING: stz_string not found at: " + $cStzStringLib
    $pStzStringHandle = NULL
ok

# ── String Functions ──

func EngineStringNew()
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_new", "p", "")

func EngineStringFrom(cStr)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_from", "p", "pi",
                     cStr, len(cStr))

func EngineStringFree(pHandle)
    if $pStzStringHandle = NULL return ok
    CallCFunc($pStzStringHandle, "stz_string_free", "v", "p", pHandle)

func EngineStringData(pHandle)
    if $pStzStringHandle = NULL return "" ok
    return CallCFunc($pStzStringHandle, "stz_string_data", "p", "p", pHandle)

func EngineStringSize(pHandle)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_size", "i", "p", pHandle)

func EngineStringCount(pHandle)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_count", "i", "p", pHandle)

func EngineStringAppend(pHandle, cStr)
    if $pStzStringHandle = NULL return ok
    CallCFunc($pStzStringHandle, "stz_string_append", "v", "ppi",
              pHandle, cStr, len(cStr))

func EngineStringIndexOf(pHandle, cNeedle)
    if $pStzStringHandle = NULL return -1 ok
    return CallCFunc($pStzStringHandle, "stz_string_index_of", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

func EngineStringContains(pHandle, cNeedle)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_contains", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

func EngineStringStartsWith(pHandle, cPrefix)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_starts_with", "i", "ppi",
                     pHandle, cPrefix, len(cPrefix))

func EngineStringEndsWith(pHandle, cSuffix)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_ends_with", "i", "ppi",
                     pHandle, cSuffix, len(cSuffix))

func EngineStringMid(pHandle, nStart, nLength)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_mid", "p", "pii",
                     pHandle, nStart, nLength)

func EngineStringLeft(pHandle, nLength)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_left", "p", "pi",
                     pHandle, nLength)

func EngineStringRight(pHandle, nLength)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_right", "p", "pi",
                     pHandle, nLength)

func EngineStringTrimmed(pHandle)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_trimmed", "p", "p",
                     pHandle)

func EngineStringReplace(pHandle, cOld, cNew)
    if $pStzStringHandle = NULL return ok
    CallCFunc($pStzStringHandle, "stz_string_replace", "v", "ppipi",
              pHandle, cOld, len(cOld), cNew, len(cNew))

func EngineStringToUpper(pHandle)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_to_upper", "p", "p",
                     pHandle)

func EngineStringToLower(pHandle)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_to_lower", "p", "p",
                     pHandle)

# ── Char Functions ──

func EngineCharUnicode(cChar)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_unicode", "i", "p", cChar)

func EngineCharIsLetter(nCodepoint)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_is_letter", "i", "i",
                     nCodepoint)

func EngineCharIsDigit(nCodepoint)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_is_digit", "i", "i",
                     nCodepoint)

func EngineCharIsUpper(nCodepoint)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_is_upper", "i", "i",
                     nCodepoint)

func EngineCharIsLower(nCodepoint)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_is_lower", "i", "i",
                     nCodepoint)
