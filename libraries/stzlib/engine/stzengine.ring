# Softanza Engine -- Ring FFI Bridge
#
# This file bridges Ring to the Softanza Engine (Zig shared library).
# It loads softanza_engine.dll/.so and wraps each C function.
#
# Usage: load "stzengine.ring" before using Engine-backed classes.
#
# NOTE: Ring's LoadLib/GetCFunc is used for dynamic loading.
# The Engine replaces Qt dependencies with pure Zig implementations.

# Detect platform and load the engine library
if isWindows()
    $cEngineLib = currentdir() + "/zig-out/bin/softanza_engine.dll"
but isLinux()
    $cEngineLib = currentdir() + "/zig-out/lib/libsoftanza_engine.so"
but isMacOS()
    $cEngineLib = currentdir() + "/zig-out/lib/libsoftanza_engine.dylib"
ok

if fexists($cEngineLib)
    $pEngineHandle = LoadLib($cEngineLib)
else
    ? "WARNING: Softanza Engine not found at: " + $cEngineLib
    ? "Run 'zig build' in the engine/ directory first."
    $pEngineHandle = NULL
ok

# ─── String Functions ───

# StzStringHandle stz_string_new(void)
func EngineStringNew()
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_new", "p", "")

# StzStringHandle stz_string_from(const char* utf8, size_t len)
func EngineStringFrom(cStr)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_from", "p", "pi",
                     cStr, len(cStr))

# void stz_string_free(StzStringHandle h)
func EngineStringFree(pHandle)
    if $pEngineHandle = NULL return ok
    CallCFunc($pEngineHandle, "stz_string_free", "v", "p", pHandle)

# const char* stz_string_data(StzStringHandle h)
func EngineStringData(pHandle)
    if $pEngineHandle = NULL return "" ok
    return CallCFunc($pEngineHandle, "stz_string_data", "p", "p", pHandle)

# size_t stz_string_size(StzStringHandle h)
func EngineStringSize(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_size", "i", "p", pHandle)

# size_t stz_string_count(StzStringHandle h)
func EngineStringCount(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_count", "i", "p", pHandle)

# void stz_string_append(StzStringHandle h, const char* utf8, size_t len)
func EngineStringAppend(pHandle, cStr)
    if $pEngineHandle = NULL return ok
    CallCFunc($pEngineHandle, "stz_string_append", "v", "ppi",
              pHandle, cStr, len(cStr))

# int64_t stz_string_index_of(StzStringHandle h, const char* needle, size_t len)
func EngineStringIndexOf(pHandle, cNeedle)
    if $pEngineHandle = NULL return -1 ok
    return CallCFunc($pEngineHandle, "stz_string_index_of", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

# int stz_string_contains(StzStringHandle h, const char* needle, size_t len)
func EngineStringContains(pHandle, cNeedle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_contains", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

# int stz_string_starts_with(StzStringHandle h, const char* prefix, size_t len)
func EngineStringStartsWith(pHandle, cPrefix)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_starts_with", "i", "ppi",
                     pHandle, cPrefix, len(cPrefix))

# int stz_string_ends_with(StzStringHandle h, const char* suffix, size_t len)
func EngineStringEndsWith(pHandle, cSuffix)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_ends_with", "i", "ppi",
                     pHandle, cSuffix, len(cSuffix))

# StzStringHandle stz_string_mid(StzStringHandle h, size_t start, size_t length)
func EngineStringMid(pHandle, nStart, nLength)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_mid", "p", "pii",
                     pHandle, nStart, nLength)

# StzStringHandle stz_string_left(StzStringHandle h, size_t length)
func EngineStringLeft(pHandle, nLength)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_left", "p", "pi",
                     pHandle, nLength)

# StzStringHandle stz_string_right(StzStringHandle h, size_t length)
func EngineStringRight(pHandle, nLength)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_right", "p", "pi",
                     pHandle, nLength)

# StzStringHandle stz_string_trimmed(StzStringHandle h)
func EngineStringTrimmed(pHandle)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_trimmed", "p", "p",
                     pHandle)

# void stz_string_replace(StzStringHandle h, old, old_len, new, new_len)
func EngineStringReplace(pHandle, cOld, cNew)
    if $pEngineHandle = NULL return ok
    CallCFunc($pEngineHandle, "stz_string_replace", "v", "ppipi",
              pHandle, cOld, len(cOld), cNew, len(cNew))

# StzStringHandle stz_string_to_upper(StzStringHandle h)
func EngineStringToUpper(pHandle)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_to_upper", "p", "p",
                     pHandle)

# StzStringHandle stz_string_to_lower(StzStringHandle h)
func EngineStringToLower(pHandle)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_to_lower", "p", "p",
                     pHandle)

# ─── Unicode Character Functions ───

# uint32_t stz_char_unicode(const char* utf8_char)
func EngineCharUnicode(cChar)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_unicode", "i", "p", cChar)

# int stz_char_is_letter(uint32_t codepoint)
func EngineCharIsLetter(nCodepoint)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_is_letter", "i", "i",
                     nCodepoint)

# int stz_char_is_digit(uint32_t codepoint)
func EngineCharIsDigit(nCodepoint)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_is_digit", "i", "i",
                     nCodepoint)

# int stz_char_is_upper(uint32_t codepoint)
func EngineCharIsUpper(nCodepoint)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_is_upper", "i", "i",
                     nCodepoint)

# int stz_char_is_lower(uint32_t codepoint)
func EngineCharIsLower(nCodepoint)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_is_lower", "i", "i",
                     nCodepoint)

# ─── Engine Version ───

func EngineVersion()
    if $pEngineHandle = NULL return "0.0.0 (not loaded)" ok
    nVer = CallCFunc($pEngineHandle, "stz_engine_version", "i", "")
    nMajor = floor(nVer / 0x01000000)
    nMinor = floor((nVer % 0x01000000) / 0x010000)
    nPatch = floor((nVer % 0x010000) / 0x0100)
    return "" + nMajor + "." + nMinor + "." + nPatch
