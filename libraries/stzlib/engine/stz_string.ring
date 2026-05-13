# Softanza Engine -- Base String + Char FFI Bridge
#
# Loads stz_string.dll -- full features, superset of Core.
# Used by: base/string/stzString.ring
# Function prefix: StzEngine* (distinct from Core StkEngine*)

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

# ── String Lifecycle (from Core) ──

func StzEngineStringNew()
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_new", "p", "")

func StzEngineStringFrom(cStr)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_from", "p", "pi",
                     cStr, len(cStr))

func StzEngineStringFree(pHandle)
    if $pStzStringHandle = NULL return ok
    CallCFunc($pStzStringHandle, "stz_string_free", "v", "p", pHandle)

# ── String Content (Core: data, size / Base adds: count) ──

func StzEngineStringData(pHandle)
    if $pStzStringHandle = NULL return "" ok
    return CallCFunc($pStzStringHandle, "stz_string_data", "p", "p", pHandle)

func StzEngineStringSize(pHandle)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_size", "i", "p", pHandle)

func StzEngineStringCount(pHandle)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_count", "i", "p", pHandle)

# ── String Mutation (Core: append / Base adds: insert) ──

func StzEngineStringAppend(pHandle, cStr)
    if $pStzStringHandle = NULL return ok
    CallCFunc($pStzStringHandle, "stz_string_append", "v", "ppi",
              pHandle, cStr, len(cStr))

func StzEngineStringInsert(pHandle, nPos, cStr)
    if $pStzStringHandle = NULL return ok
    CallCFunc($pStzStringHandle, "stz_string_insert", "v", "pipi",
              pHandle, nPos, cStr, len(cStr))

# ── String Extraction (Base only) ──

func StzEngineStringMid(pHandle, nStart, nLength)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_mid", "p", "pii",
                     pHandle, nStart, nLength)

func StzEngineStringLeft(pHandle, nLength)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_left", "p", "pi",
                     pHandle, nLength)

func StzEngineStringRight(pHandle, nLength)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_right", "p", "pi",
                     pHandle, nLength)

func StzEngineStringTrimmed(pHandle)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_trimmed", "p", "p",
                     pHandle)

# ── String Search (Core: index_of, contains / Base adds: rest) ──

func StzEngineStringIndexOf(pHandle, cNeedle)
    if $pStzStringHandle = NULL return -1 ok
    return CallCFunc($pStzStringHandle, "stz_string_index_of", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

func StzEngineStringLastIndexOf(pHandle, cNeedle)
    if $pStzStringHandle = NULL return -1 ok
    return CallCFunc($pStzStringHandle, "stz_string_last_index_of", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

func StzEngineStringContains(pHandle, cNeedle)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_contains", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

func StzEngineStringStartsWith(pHandle, cPrefix)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_starts_with", "i", "ppi",
                     pHandle, cPrefix, len(cPrefix))

func StzEngineStringEndsWith(pHandle, cSuffix)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_string_ends_with", "i", "ppi",
                     pHandle, cSuffix, len(cSuffix))

# ── String Transform (Base only) ──

func StzEngineStringReplace(pHandle, cOld, cNew)
    if $pStzStringHandle = NULL return ok
    CallCFunc($pStzStringHandle, "stz_string_replace", "v", "ppipi",
              pHandle, cOld, len(cOld), cNew, len(cNew))

func StzEngineStringToUpper(pHandle)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_to_upper", "p", "p",
                     pHandle)

func StzEngineStringToLower(pHandle)
    if $pStzStringHandle = NULL return NULL ok
    return CallCFunc($pStzStringHandle, "stz_string_to_lower", "p", "p",
                     pHandle)

# ── Char (Core: unicode, to_utf8, is_letter, is_digit / Base adds: is_upper, is_lower) ──

func StzEngineCharUnicode(cChar)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_unicode", "i", "p", cChar)

func StzEngineCharToUtf8(nCodepoint, cBuf, nBufLen)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_to_utf8", "i", "ipi",
                     nCodepoint, cBuf, nBufLen)

func StzEngineCharIsLetter(nCodepoint)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_is_letter", "i", "i",
                     nCodepoint)

func StzEngineCharIsDigit(nCodepoint)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_is_digit", "i", "i",
                     nCodepoint)

func StzEngineCharIsUpper(nCodepoint)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_is_upper", "i", "i",
                     nCodepoint)

func StzEngineCharIsLower(nCodepoint)
    if $pStzStringHandle = NULL return 0 ok
    return CallCFunc($pStzStringHandle, "stz_char_is_lower", "i", "i",
                     nCodepoint)
