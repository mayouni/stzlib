# Softanza Engine -- Core String + Char FFI Bridge
#
# Loads stk_string.dll -- minimal subset for constrained environments.
# Used by: core/string/stkString.ring, core/string/stkChar.ring

if isWindows()
    $cStkStringLib = currentdir() + "/zig-out/bin/stk_string.dll"
but isLinux()
    $cStkStringLib = currentdir() + "/zig-out/lib/libstk_string.so"
but isMacOS()
    $cStkStringLib = currentdir() + "/zig-out/lib/libstk_string.dylib"
ok

if fexists($cStkStringLib)
    $pStkStringHandle = LoadLib($cStkStringLib)
else
    ? "WARNING: stk_string not found at: " + $cStkStringLib
    $pStkStringHandle = NULL
ok

# ── Core String Functions ──

func EngineStringNew()
    if $pStkStringHandle = NULL return NULL ok
    return CallCFunc($pStkStringHandle, "stz_string_new", "p", "")

func EngineStringFrom(cStr)
    if $pStkStringHandle = NULL return NULL ok
    return CallCFunc($pStkStringHandle, "stz_string_from", "p", "pi",
                     cStr, len(cStr))

func EngineStringFree(pHandle)
    if $pStkStringHandle = NULL return ok
    CallCFunc($pStkStringHandle, "stz_string_free", "v", "p", pHandle)

func EngineStringData(pHandle)
    if $pStkStringHandle = NULL return "" ok
    return CallCFunc($pStkStringHandle, "stz_string_data", "p", "p", pHandle)

func EngineStringSize(pHandle)
    if $pStkStringHandle = NULL return 0 ok
    return CallCFunc($pStkStringHandle, "stz_string_size", "i", "p", pHandle)

func EngineStringAppend(pHandle, cStr)
    if $pStkStringHandle = NULL return ok
    CallCFunc($pStkStringHandle, "stz_string_append", "v", "ppi",
              pHandle, cStr, len(cStr))

func EngineStringIndexOf(pHandle, cNeedle)
    if $pStkStringHandle = NULL return -1 ok
    return CallCFunc($pStkStringHandle, "stz_string_index_of", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

func EngineStringContains(pHandle, cNeedle)
    if $pStkStringHandle = NULL return 0 ok
    return CallCFunc($pStkStringHandle, "stz_string_contains", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

# ── Core Char Functions ──

func EngineCharUnicode(cChar)
    if $pStkStringHandle = NULL return 0 ok
    return CallCFunc($pStkStringHandle, "stz_char_unicode", "i", "p", cChar)

func EngineCharIsLetter(nCodepoint)
    if $pStkStringHandle = NULL return 0 ok
    return CallCFunc($pStkStringHandle, "stz_char_is_letter", "i", "i",
                     nCodepoint)

func EngineCharIsDigit(nCodepoint)
    if $pStkStringHandle = NULL return 0 ok
    return CallCFunc($pStkStringHandle, "stz_char_is_digit", "i", "i",
                     nCodepoint)
