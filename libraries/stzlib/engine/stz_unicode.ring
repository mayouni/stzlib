# Softanza Engine -- Base Unicode FFI Bridge
#
# Loads stz_unicode.dll -- full Unicode character properties, case
# conversion, normalization, grapheme clusters, diacritic stripping.
# Used by: base/unicode/stzUnicode.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzUnicodeLib = $cEngineDir + "/zig-out/bin/stz_unicode.dll"
but isLinux()
    $cStzUnicodeLib = $cEngineDir + "/zig-out/lib/libstz_unicode.so"
but isMacOS()
    $cStzUnicodeLib = $cEngineDir + "/zig-out/lib/libstz_unicode.dylib"
ok

if fexists($cStzUnicodeLib)
    $pStzUnicodeHandle = LoadLib($cStzUnicodeLib)
else
    ? "WARNING: stz_unicode not found at: " + $cStzUnicodeLib
    $pStzUnicodeHandle = NULL
ok

# ── Character Properties ──

func StzEngineUnicodeCategory(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_category", "i", "i",
                     nCodepoint)

func StzEngineUnicodeCategoryString(nCodepoint)
    if $pStzUnicodeHandle = NULL return "" ok
    cBuf = space(4)
    nLen = CallCFunc($pStzUnicodeHandle, "stz_unicode_category_string", "i", "ipi",
                     nCodepoint, cBuf, 4)
    return left(cBuf, nLen)

func StzEngineUnicodeIsLetter(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_letter", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsDigit(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_digit", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsNumber(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_number", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsUpper(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_upper", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsLower(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_lower", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsSpace(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_space", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsPunctuation(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_punctuation", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsSymbol(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_symbol", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsMark(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_mark", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsControl(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_control", "i", "i",
                     nCodepoint)

func StzEngineUnicodeIsValid(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_is_valid", "i", "i",
                     nCodepoint)

func StzEngineUnicodeBidiClass(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_bidi_class", "i", "i",
                     nCodepoint)

func StzEngineUnicodeCharWidth(nCodepoint)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_charwidth", "i", "i",
                     nCodepoint)

# ── Case Conversion (codepoint level) ──

func StzEngineUnicodeToLower(nCodepoint)
    if $pStzUnicodeHandle = NULL return nCodepoint ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_to_lower", "i", "i",
                     nCodepoint)

func StzEngineUnicodeToUpper(nCodepoint)
    if $pStzUnicodeHandle = NULL return nCodepoint ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_to_upper", "i", "i",
                     nCodepoint)

func StzEngineUnicodeToTitle(nCodepoint)
    if $pStzUnicodeHandle = NULL return nCodepoint ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_to_title", "i", "i",
                     nCodepoint)

# ── String-level Case Conversion ──

func StzEngineUnicodeToLowerStr(cStr)
    if $pStzUnicodeHandle = NULL return cStr ok
    nLen = len(cStr)
    nBufLen = nLen * 4
    cBuf = space(nBufLen)
    nOut = CallCFunc($pStzUnicodeHandle, "stz_unicode_to_lower_str", "i", "pipi",
                     cStr, nLen, cBuf, nBufLen)
    return left(cBuf, nOut)

func StzEngineUnicodeToUpperStr(cStr)
    if $pStzUnicodeHandle = NULL return cStr ok
    nLen = len(cStr)
    nBufLen = nLen * 4
    cBuf = space(nBufLen)
    nOut = CallCFunc($pStzUnicodeHandle, "stz_unicode_to_upper_str", "i", "pipi",
                     cStr, nLen, cBuf, nBufLen)
    return left(cBuf, nOut)

func StzEngineUnicodeToTitleStr(cStr)
    if $pStzUnicodeHandle = NULL return cStr ok
    nLen = len(cStr)
    nBufLen = nLen * 4
    cBuf = space(nBufLen)
    nOut = CallCFunc($pStzUnicodeHandle, "stz_unicode_to_title_str", "i", "pipi",
                     cStr, nLen, cBuf, nBufLen)
    return left(cBuf, nOut)

# ── Normalization ──
# form: 0=NFC, 1=NFD, 2=NFKC, 3=NFKD

func StzEngineUnicodeNormalize(cStr, nForm)
    if $pStzUnicodeHandle = NULL return cStr ok
    nOutLen = 0
    pData = CallCFunc($pStzUnicodeHandle, "stz_unicode_normalize", "p", "piip",
                      cStr, len(cStr), nForm, :nOutLen)
    if pData = NULL return cStr ok
    cResult = copy(pData, nOutLen)
    CallCFunc($pStzUnicodeHandle, "stz_unicode_normalize_free", "v", "pi",
              pData, nOutLen)
    return cResult

# ── Case Folding ──

func StzEngineUnicodeCaseFold(cStr)
    if $pStzUnicodeHandle = NULL return cStr ok
    nOutLen = 0
    pData = CallCFunc($pStzUnicodeHandle, "stz_unicode_casefold", "p", "pip",
                      cStr, len(cStr), :nOutLen)
    if pData = NULL return cStr ok
    cResult = copy(pData, nOutLen)
    CallCFunc($pStzUnicodeHandle, "stz_unicode_casefold_free", "v", "pi",
              pData, nOutLen)
    return cResult

# ── Strip Marks (diacritics) ──

func StzEngineUnicodeStripMarks(cStr)
    if $pStzUnicodeHandle = NULL return cStr ok
    nOutLen = 0
    pData = CallCFunc($pStzUnicodeHandle, "stz_unicode_strip_marks", "p", "pip",
                      cStr, len(cStr), :nOutLen)
    if pData = NULL return cStr ok
    cResult = copy(pData, nOutLen)
    CallCFunc($pStzUnicodeHandle, "stz_unicode_strip_marks_free", "v", "pi",
              pData, nOutLen)
    return cResult

# ── Grapheme Clusters ──

func StzEngineUnicodeGraphemeCount(cStr)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_grapheme_count", "i", "pi",
                     cStr, len(cStr))

func StzEngineUnicodeGraphemeBreak(nCodepoint1, nCodepoint2)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_grapheme_break", "i", "ii",
                     nCodepoint1, nCodepoint2)

# ── UTF-8 Iteration ──

func StzEngineUnicodeIterate(cStr, nPos)
    if $pStzUnicodeHandle = NULL return -1 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_iterate", "i", "pii",
                     cStr, len(cStr), nPos)

func StzEngineUnicodeCpByteLen(cStr, nPos)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_cp_byte_len", "i", "pii",
                     cStr, len(cStr), nPos)

func StzEngineUnicodeEncode(nCodepoint, cBuf, nBufLen)
    if $pStzUnicodeHandle = NULL return 0 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_encode", "i", "ipi",
                     nCodepoint, cBuf, nBufLen)

# ── Codepoint-to-byte offset mapping ──

func StzEngineUnicodeCpToByte(cStr, nCpIndex)
    if $pStzUnicodeHandle = NULL return -1 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_cp_to_byte", "i", "pii",
                     cStr, len(cStr), nCpIndex)

func StzEngineUnicodeByteToCp(cStr, nBytePos)
    if $pStzUnicodeHandle = NULL return -1 ok
    return CallCFunc($pStzUnicodeHandle, "stz_unicode_byte_to_cp", "i", "pii",
                     cStr, len(cStr), nBytePos)
