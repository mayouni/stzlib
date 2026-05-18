? "Engine Full Bridge Test -- All 339 Registered Functions"
? "======================================================"


# Load Engine DLL directly (no stzlib dependency)
# Run from the engine/test/ directory: ring engine_bridge_test.ring
cDll = currentdir() + "/../zig-out/bin/stz_string.dll"
if NOT fexists(cDll)
	# Try Windows backslash variant
	cDll = currentdir() + "\..\zig-out\bin\stz_string.dll"
ok

if NOT fexists(cDll)
	? "ERROR: DLL not found at: " + cDll
	return
ok

pLib = LoadLib(cDll)
? "Engine DLL loaded from: " + cDll


nPass = 0
nFail = 0
nTotal = 0

# ==============================================================
#  GROUP 1: Lifecycle -- New, From, Free, Data, Size, Count
# ==============================================================

? NL + "--- Group 1: Lifecycle ---"

pNew = StzEngineStringNew()
Assert("StringNew returns handle", type(pNew) != "NUMBER", true)
StzEngineStringFree(pNew)

pStr = StzEngineString("Hello")
Assert("StringFrom + Data", StzEngineStringData(pStr), "Hello")
Assert("StringSize (bytes)", StzEngineStringSize(pStr), 5)
Assert("StringCount (codepoints)", StzEngineStringCount(pStr), 5)
StzEngineStringFree(pStr)

# Unicode: 3-byte chars
pUni = StzEngineString("ABC")
Assert("StringCount ASCII", StzEngineStringCount(pUni), 3)
StzEngineStringFree(pUni)

# ==============================================================
#  GROUP 2: Append, Insert, Mid
# ==============================================================

? NL + "--- Group 2: Append, Insert, Mid ---"

pStr = StzEngineString("Hello")
StzEngineStringAppend(pStr, " World")
Assert("Append", StzEngineStringData(pStr), "Hello World")

# Insert at byte position 5
pStr2 = StzEngineString("HelloWorld")
StzEngineStringInsert(pStr2, 5, " ")
Assert("Insert byte", StzEngineStringData(pStr2), "Hello World")

# Mid: extract from byte 6, length 5
pMid = StzEngineStringMid(pStr, 6, 5)
Assert("Mid", StzEngineStringData(pMid), "World")
StzEngineStringFree(pMid)

StzEngineStringFree(pStr)
StzEngineStringFree(pStr2)

# ==============================================================
#  GROUP 3: Trimmed
# ==============================================================

? NL + "--- Group 3: Trimmed ---"

pStr = StzEngineString("  hello  ")
pTrimmed = StzEngineStringTrimmed(pStr)
Assert("Trimmed", StzEngineStringData(pTrimmed), "hello")
StzEngineStringFree(pTrimmed)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 4: IndexOf, IndexOfFrom, IndexOfCI
# ==============================================================

? NL + "--- Group 4: IndexOf, IndexOfFrom, IndexOfCI ---"

pStr = StzEngineString("hello world hello")
nIdx = StzEngineStringIndexOf(pStr, "world")
Assert("IndexOf found", nIdx, 7)

nIdx = StzEngineStringIndexOf(pStr, "xyz")
Assert("IndexOf not found", nIdx < 0, true)

nIdx = StzEngineStringIndexOfFrom(pStr, "hello", 1)
Assert("IndexOfFrom pos 0", nIdx, 1)

nIdx = StzEngineStringIndexOfFrom(pStr, "hello", 2)
Assert("IndexOfFrom pos 1 (second)", nIdx, 13)

nIdx = StzEngineStringIndexOfCI(pStr, "HELLO", 1)
Assert("IndexOfCI", nIdx, 1)

nIdx = StzEngineStringIndexOfCI(pStr, "WORLD", 1)
Assert("IndexOfCI world", nIdx, 7)

StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 5: ByteToCp
# ==============================================================

? NL + "--- Group 5: ByteToCp ---"

pStr = StzEngineString("hello")
nCp = StzEngineStringByteToCp(pStr, 3)
Assert("ByteToCp ASCII", nCp, 4)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 6: CountOf, CountOfCI, LastIndexOf, LastIndexOfCI
# ==============================================================

? NL + "--- Group 6: CountOf, LastIndexOf ---"

pStr = StzEngineString("abc-abc-abc")
Assert("CountOf", StzEngineStringCountOf(pStr, "abc"), 3)
Assert("CountOf not found", StzEngineStringCountOf(pStr, "xyz"), 0)
Assert("LastIndexOf", StzEngineStringLastIndexOf(pStr, "abc"), 9)
Assert("LastIndexOf not found", StzEngineStringLastIndexOf(pStr, "xyz") < 0, true)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello hello HELLO")
Assert("CountOfCI", StzEngineStringCountOfCI(pStr, "hello"), 3)
Assert("LastIndexOfCI", StzEngineStringLastIndexOfCI(pStr, "hello"), 13)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 7: Contains, ContainsCI, StartsWith, StartsWithCI,
#           EndsWith, EndsWithCI
# ==============================================================

? NL + "--- Group 7: Contains, StartsWith, EndsWith ---"

pStr = StzEngineString("Hello World")
Assert("Contains yes", StzEngineStringContains(pStr, "World"), 1)
Assert("Contains no", StzEngineStringContains(pStr, "xyz"), 0)
Assert("ContainsCI", StzEngineStringContainsCI(pStr, "WORLD"), 1)
Assert("ContainsCI no", StzEngineStringContainsCI(pStr, "xyz"), 0)
Assert("StartsWith yes", StzEngineStringStartsWith(pStr, "Hello"), 1)
Assert("StartsWith no", StzEngineStringStartsWith(pStr, "World"), 0)
Assert("StartsWithCI", StzEngineStringStartsWithCI(pStr, "hello"), 1)
Assert("EndsWith yes", StzEngineStringEndsWith(pStr, "World"), 1)
Assert("EndsWith no", StzEngineStringEndsWith(pStr, "Hello"), 0)
Assert("EndsWithCI", StzEngineStringEndsWithCI(pStr, "world"), 1)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 8: FindAll, FindAllCI, FindResultCount/Get/Free
# ==============================================================

? NL + "--- Group 8: FindAll, FindAllCI ---"

pStr = StzEngineString("abc-abc-abc")
pResult = StzEngineStringFindAll(pStr, "abc")
nCount = StzEngineFindResultCount(pResult)
Assert("FindAll count", nCount, 3)
Assert("FindAll pos 0", StzEngineFindResultGet(pResult, 0), 1)
Assert("FindAll pos 1", StzEngineFindResultGet(pResult, 1), 5)
Assert("FindAll pos 2", StzEngineFindResultGet(pResult, 2), 9)
StzEngineFindResultFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello hello HELLO")
pResult = StzEngineStringFindAllCI(pStr, "hello")
nCount = StzEngineFindResultCount(pResult)
Assert("FindAllCI count", nCount, 3)
Assert("FindAllCI pos 0", StzEngineFindResultGet(pResult, 0), 1)
Assert("FindAllCI pos 1", StzEngineFindResultGet(pResult, 1), 7)
Assert("FindAllCI pos 2", StzEngineFindResultGet(pResult, 2), 13)
StzEngineFindResultFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 9: SplitCount, SplitGet, SplitCountCI, SplitGetCI
# ==============================================================

? NL + "--- Group 9: Split ---"

pStr = StzEngineString("one::two::three")
Assert("SplitCount", StzEngineStringSplitCount(pStr, "::"), 3)
pP0 = StzEngineStringSplitGet(pStr, "::", 0)
Assert("SplitGet 0", StzEngineStringData(pP0), "one")
StzEngineStringFree(pP0)
pP1 = StzEngineStringSplitGet(pStr, "::", 1)
Assert("SplitGet 1", StzEngineStringData(pP1), "two")
StzEngineStringFree(pP1)
pP2 = StzEngineStringSplitGet(pStr, "::", 2)
Assert("SplitGet 2", StzEngineStringData(pP2), "three")
StzEngineStringFree(pP2)
StzEngineStringFree(pStr)

pStr = StzEngineString("aXbXc")
Assert("SplitCountCI", StzEngineStringSplitCountCI(pStr, "x"), 3)
pP0 = StzEngineStringSplitGetCI(pStr, "x", 0)
Assert("SplitGetCI 0", StzEngineStringData(pP0), "a")
StzEngineStringFree(pP0)
pP1 = StzEngineStringSplitGetCI(pStr, "x", 1)
Assert("SplitGetCI 1", StzEngineStringData(pP1), "b")
StzEngineStringFree(pP1)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 10: Replace, ReplaceCI, ReplaceRange
# ==============================================================

? NL + "--- Group 10: Replace ---"

pStr = StzEngineString("hello world hello")
StzEngineStringReplace(pStr, "hello", "HI")
Assert("Replace", StzEngineStringData(pStr), "HI world HI")
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello HELLO hello")
StzEngineStringReplaceCI(pStr, "hello", "X")
Assert("ReplaceCI", StzEngineStringData(pStr), "X X X")
StzEngineStringFree(pStr)

pStr = StzEngineString("ABCDEF")
pRR = StzEngineStringReplaceRange(pStr, 2, 2, "xx")
Assert("ReplaceRange", StzEngineStringData(pRR), "ABxxEF")
StzEngineStringFree(pRR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 11: ToUpper, ToLower, ToTitle
# ==============================================================

? NL + "--- Group 11: Case Conversion ---"

pStr = StzEngineString("Hello World")
pUp = StzEngineStringToUpper(pStr)
Assert("ToUpper", StzEngineStringData(pUp), "HELLO WORLD")
StzEngineStringFree(pUp)

pLo = StzEngineStringToLower(pStr)
Assert("ToLower", StzEngineStringData(pLo), "hello world")
StzEngineStringFree(pLo)

pStr2 = StzEngineString("hello world")
pTi = StzEngineStringToTitle(pStr2)
cTitle = StzEngineStringData(pTi)
Assert("ToTitle first H", substr(cTitle, 1, 1), "H")
StzEngineStringFree(pTi)
StzEngineStringFree(pStr)
StzEngineStringFree(pStr2)

# ==============================================================
#  GROUP 12: CharAt, MidCp, NthChar, Slice
# ==============================================================

? NL + "--- Group 12: CharAt, MidCp, NthChar, Slice ---"

pStr = StzEngineString("Hello")
nCh = StzEngineStringCharAt(pStr, 1)
Assert("CharAt 0 = H (72)", nCh, 72)

nCh = StzEngineStringCharAt(pStr, 5)
Assert("CharAt 4 = o (111)", nCh, 111)

pMid = StzEngineStringMidCp(pStr, 2, 3)
Assert("MidCp(1,3)", StzEngineStringData(pMid), "ell")
StzEngineStringFree(pMid)

pNth = StzEngineStringNthChar(pStr, 1)
Assert("NthChar 0", StzEngineStringData(pNth), "H")
StzEngineStringFree(pNth)
pNth = StzEngineStringNthChar(pStr, 5)
Assert("NthChar 4", StzEngineStringData(pNth), "o")
StzEngineStringFree(pNth)

pSlice = StzEngineStringSlice(pStr, 2, 3)
Assert("Slice(1,3)", StzEngineStringData(pSlice), "ell")
StzEngineStringFree(pSlice)

StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 13: GraphemeCount, Normalize, StripMarks
# ==============================================================

? NL + "--- Group 13: GraphemeCount, Normalize, StripMarks ---"

pStr = StzEngineString("Hello")
nGr = StzEngineStringGraphemeCount(pStr)
Assert("GraphemeCount ASCII", nGr, 5)
StzEngineStringFree(pStr)

# Normalize NFC (form=0)
pStr = StzEngineString("test")
pNorm = StzEngineStringNormalize(pStr, 0)
Assert("Normalize NFC", StzEngineStringData(pNorm), "test")
StzEngineStringFree(pNorm)
StzEngineStringFree(pStr)

# StripMarks on ASCII (no change)
pStr = StzEngineString("Hello")
pStripped = StzEngineStringStripMarks(pStr)
Assert("StripMarks ASCII", StzEngineStringData(pStripped), "Hello")
StzEngineStringFree(pStripped)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 14: Char module -- CharUnicode, CharIsLetter/Digit/Upper/Lower
# ==============================================================

? NL + "--- Group 14: Char module ---"

Assert("CharUnicode 'A'=65", StzEngineCharUnicode("A"), 65)
Assert("CharIsLetter 'A'", StzEngineCharIsLetter(65), 1)
Assert("CharIsLetter '5'", StzEngineCharIsLetter(53), 0)
Assert("CharIsDigit '5'", StzEngineCharIsDigit(53), 1)
Assert("CharIsDigit 'A'", StzEngineCharIsDigit(65), 0)
Assert("CharIsUpper 'A'", StzEngineCharIsUpper(65), 1)
Assert("CharIsUpper 'a'", StzEngineCharIsUpper(97), 0)
Assert("CharIsLower 'a'", StzEngineCharIsLower(97), 1)
Assert("CharIsLower 'A'", StzEngineCharIsLower(65), 0)

# ==============================================================
#  GROUP 15: Reverse, Repeat, PadLeft, PadRight
# ==============================================================

? NL + "--- Group 15: Reverse, Repeat, Pad ---"

pStr = StzEngineString("Hello")
pRev = StzEngineStringReverse(pStr)
Assert("Reverse", StzEngineStringData(pRev), "olleH")
StzEngineStringFree(pRev)
StzEngineStringFree(pStr)

pStr = StzEngineString("ab")
pRep = StzEngineStringRepeat(pStr, 3)
Assert("Repeat 3", StzEngineStringData(pRep), "ababab")
StzEngineStringFree(pRep)
StzEngineStringFree(pStr)

pStr = StzEngineString("hi")
pPL = StzEngineStringPadLeft(pStr, 5, "*")
Assert("PadLeft", StzEngineStringData(pPL), "***hi")
StzEngineStringFree(pPL)
pPR = StzEngineStringPadRight(pStr, 5, ".")
Assert("PadRight", StzEngineStringData(pPR), "hi...")
StzEngineStringFree(pPR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 16: RemoveRange, TrimLeft, TrimRight
# ==============================================================

? NL + "--- Group 16: RemoveRange, TrimLeft, TrimRight ---"

pStr = StzEngineString("ABCDEF")
pRR = StzEngineStringRemoveRange(pStr, 3, 2)
Assert("RemoveRange", StzEngineStringData(pRR), "ABEF")
StzEngineStringFree(pRR)
StzEngineStringFree(pStr)

pStr = StzEngineString("   hello")
pTL = StzEngineStringTrimLeft(pStr)
Assert("TrimLeft", StzEngineStringData(pTL), "hello")
StzEngineStringFree(pTL)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello   ")
pTR = StzEngineStringTrimRight(pStr)
Assert("TrimRight", StzEngineStringData(pTR), "hello")
StzEngineStringFree(pTR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 17: Equals, EqualsCI
# ==============================================================

? NL + "--- Group 17: Equals ---"

pStr1 = StzEngineString("Hello")
pStr2 = StzEngineString("Hello")
pStr3 = StzEngineString("hello")
Assert("Equals same", StzEngineStringEquals(pStr1, pStr2), 1)
Assert("Equals diff case", StzEngineStringEquals(pStr1, pStr3), 0)
Assert("EqualsCI", StzEngineStringEqualsCI(pStr1, pStr3), 1)
StzEngineStringFree(pStr1)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr3)

# ==============================================================
#  GROUP 18: ReplaceFirst, ReplaceLast, ReplaceNth
# ==============================================================

? NL + "--- Group 18: ReplaceFirst/Last/Nth ---"

pStr = StzEngineString("abc-abc-abc")
pRF = StzEngineStringReplaceFirst(pStr, "abc", "X")
Assert("ReplaceFirst", StzEngineStringData(pRF), "X-abc-abc")
StzEngineStringFree(pRF)

pRL = StzEngineStringReplaceLast(pStr, "abc", "Y")
Assert("ReplaceLast", StzEngineStringData(pRL), "abc-abc-Y")
StzEngineStringFree(pRL)

pRN = StzEngineStringReplaceNth(pStr, "abc", "Z", 2)
Assert("ReplaceNth 2", StzEngineStringData(pRN), "abc-Z-abc")
StzEngineStringFree(pRN)

StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 19: IsEmpty, Between
# ==============================================================

? NL + "--- Group 19: IsEmpty, Between ---"

pEmpty = StzEngineString("")
Assert("IsEmpty yes", StzEngineStringIsEmpty(pEmpty), 1)
StzEngineStringFree(pEmpty)

pStr = StzEngineString("hello")
Assert("IsEmpty no", StzEngineStringIsEmpty(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("[hello world]")
pBet = StzEngineStringBetween(pStr, "[", "]")
Assert("Between []", StzEngineStringData(pBet), "hello world")
StzEngineStringFree(pBet)
StzEngineStringFree(pStr)

pStr = StzEngineString("<<value>>")
pBet = StzEngineStringBetween(pStr, "<<", ">>")
Assert("Between << >>", StzEngineStringData(pBet), "value")
StzEngineStringFree(pBet)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 20: CountCharsOfType, IsNumeric, IsAlpha
# ==============================================================

? NL + "--- Group 20: CountCharsOfType, IsNumeric, IsAlpha ---"

pStr = StzEngineString("Hello 123!")
Assert("CountCharsOfType letters", StzEngineStringCountCharsOfType(pStr, 0), 5)
Assert("CountCharsOfType digits", StzEngineStringCountCharsOfType(pStr, 1), 3)
Assert("CountCharsOfType spaces", StzEngineStringCountCharsOfType(pStr, 2), 1)
Assert("CountCharsOfType upper", StzEngineStringCountCharsOfType(pStr, 3), 1)
Assert("CountCharsOfType lower", StzEngineStringCountCharsOfType(pStr, 4), 4)
Assert("CountCharsOfType punct", StzEngineStringCountCharsOfType(pStr, 5), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("12345")
Assert("IsNumeric yes", StzEngineStringIsNumeric(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("12a45")
Assert("IsNumeric no", StzEngineStringIsNumeric(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello")
Assert("IsAlpha yes", StzEngineStringIsAlpha(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello1")
Assert("IsAlpha no", StzEngineStringIsAlpha(pStr), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 21: FindNth, FindNthCI
# ==============================================================

? NL + "--- Group 21: FindNth ---"

pStr = StzEngineString("abc-abc-abc")
Assert("FindNth 1", StzEngineStringFindNth(pStr, "abc", 1), 1)
Assert("FindNth 2", StzEngineStringFindNth(pStr, "abc", 2), 5)
Assert("FindNth 3", StzEngineStringFindNth(pStr, "abc", 3), 9)
Assert("FindNth 4 (not found)", StzEngineStringFindNth(pStr, "abc", 4) < 0, true)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello hello HELLO")
Assert("FindNthCI 1", StzEngineStringFindNthCI(pStr, "hello", 1), 1)
Assert("FindNthCI 2", StzEngineStringFindNthCI(pStr, "hello", 2), 7)
Assert("FindNthCI 3", StzEngineStringFindNthCI(pStr, "hello", 3), 13)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 22: InsertCp, LeftCp, RightCp
# ==============================================================

? NL + "--- Group 22: InsertCp, LeftCp, RightCp ---"

pStr = StzEngineString("HelloWorld")
StzEngineStringInsertCp(pStr, 6, " ")
Assert("InsertCp", StzEngineStringData(pStr), "Hello World")
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello World")
pLeft = StzEngineStringLeftCp(pStr, 5)
Assert("LeftCp", StzEngineStringData(pLeft), "Hello")
StzEngineStringFree(pLeft)

pRight = StzEngineStringRightCp(pStr, 5)
Assert("RightCp", StzEngineStringData(pRight), "World")
StzEngineStringFree(pRight)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 23: RemoveAll, LinesCount, IsPalindrome, Concat
# ==============================================================

? NL + "--- Group 23: RemoveAll, LinesCount, IsPalindrome, Concat ---"

pStr = StzEngineString("abc--def--ghi")
pRemoved = StzEngineStringRemoveAll(pStr, "--")
Assert("RemoveAll", StzEngineStringData(pRemoved), "abcdefghi")
StzEngineStringFree(pRemoved)
StzEngineStringFree(pStr)

pStr = StzEngineString("line1" + char(10) + "line2" + char(10) + "line3")
Assert("LinesCount 3", StzEngineStringLinesCount(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
Assert("LinesCount 1", StzEngineStringLinesCount(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("")
Assert("LinesCount empty", StzEngineStringLinesCount(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("racecar")
Assert("IsPalindrome yes", StzEngineStringIsPalindrome(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
Assert("IsPalindrome no", StzEngineStringIsPalindrome(pStr), 0)
StzEngineStringFree(pStr)

pStr1 = StzEngineString("Hello ")
pStr2 = StzEngineString("World")
pConcat = StzEngineStringConcat(pStr1, pStr2)
Assert("Concat", StzEngineStringData(pConcat), "Hello World")
StzEngineStringFree(pConcat)
StzEngineStringFree(pStr1)
StzEngineStringFree(pStr2)

# ==============================================================
#  GROUP 24: IsAscii, RemoveCharAt, CharTypeAt
# ==============================================================

? NL + "--- Group 24: IsAscii, RemoveCharAt, CharTypeAt ---"

pStr = StzEngineString("Hello")
Assert("IsAscii yes", StzEngineStringIsAscii(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("ABCDE")
pRemoved = StzEngineStringRemoveCharAt(pStr, 3)
Assert("RemoveCharAt 2", StzEngineStringData(pRemoved), "ABDE")
StzEngineStringFree(pRemoved)
StzEngineStringFree(pStr)

pStr = StzEngineString("A1 !")
Assert("CharTypeAt 0 upper", StzEngineStringCharTypeAt(pStr, 1), 3)
Assert("CharTypeAt 1 digit", StzEngineStringCharTypeAt(pStr, 2), 1)
Assert("CharTypeAt 2 space", StzEngineStringCharTypeAt(pStr, 3), 2)
Assert("CharTypeAt 3 punct", StzEngineStringCharTypeAt(pStr, 4), 5)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 25: FindCharsOfType, ExtractCharsOfType
# ==============================================================

? NL + "--- Group 25: FindCharsOfType, ExtractCharsOfType ---"

pStr = StzEngineString("a1b2c3")
pResult = StzEngineStringFindCharsOfType(pStr, 1)  # digits
nCount = StzEngineFindResultCount(pResult)
Assert("FindCharsOfType digit count", nCount, 3)
Assert("FindCharsOfType digit pos0", StzEngineFindResultGet(pResult, 0), 2)
Assert("FindCharsOfType digit pos1", StzEngineFindResultGet(pResult, 1), 4)
Assert("FindCharsOfType digit pos2", StzEngineFindResultGet(pResult, 2), 6)
StzEngineFindResultFree(pResult)

pExtracted = StzEngineStringExtractCharsOfType(pStr, 0) # letters
Assert("ExtractCharsOfType letters", StzEngineStringData(pExtracted), "abc")
StzEngineStringFree(pExtracted)

pExtracted = StzEngineStringExtractCharsOfType(pStr, 1) # digits
Assert("ExtractCharsOfType digits", StzEngineStringData(pExtracted), "123")
StzEngineStringFree(pExtracted)

StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 26: IsUppercase, IsLowercase, IsWhitespace, WordCount, IsOnlyType
# ==============================================================

? NL + "--- Group 26: IsUppercase, IsLowercase, IsWhitespace, WordCount, IsOnlyType ---"

pStr = StzEngineString("HELLO")
Assert("IsUppercase yes", StzEngineStringIsUppercase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello")
Assert("IsUppercase no", StzEngineStringIsUppercase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("HELLO 123!")
Assert("IsUppercase with non-letters", StzEngineStringIsUppercase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
Assert("IsLowercase yes", StzEngineStringIsLowercase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello")
Assert("IsLowercase no", StzEngineStringIsLowercase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("   ")
Assert("IsWhitespace yes", StzEngineStringIsWhitespace(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString(" a ")
Assert("IsWhitespace no", StzEngineStringIsWhitespace(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("")
Assert("IsWhitespace empty", StzEngineStringIsWhitespace(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
Assert("WordCount 2", StzEngineStringWordCount(pStr), 2)
StzEngineStringFree(pStr)

pStr = StzEngineString("  hello   world  ")
Assert("WordCount 2 padded", StzEngineStringWordCount(pStr), 2)
StzEngineStringFree(pStr)

pStr = StzEngineString("one")
Assert("WordCount 1", StzEngineStringWordCount(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("")
Assert("WordCount 0", StzEngineStringWordCount(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
Assert("IsOnlyType letters", StzEngineStringIsOnlyType(pStr, 0), 1)
Assert("IsOnlyType digits", StzEngineStringIsOnlyType(pStr, 1), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("123")
Assert("IsOnlyType digits", StzEngineStringIsOnlyType(pStr, 1), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("   ")
Assert("IsOnlyType spaces", StzEngineStringIsOnlyType(pStr, 2), 1)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 27: RemoveCharsOfType, Trim, SwapCase
# ==============================================================

? NL + "--- Group 27: RemoveCharsOfType, Trim, SwapCase ---"

pStr = StzEngineString("Hello 123!")
pRem = StzEngineStringRemoveCharsOfType(pStr, 1)  # remove digits
Assert("RemoveCharsOfType digits", StzEngineStringData(pRem), "Hello !")
StzEngineStringFree(pRem)
pRem = StzEngineStringRemoveCharsOfType(pStr, 2)  # remove spaces
Assert("RemoveCharsOfType spaces", StzEngineStringData(pRem), "Hello123!")
StzEngineStringFree(pRem)
pRem = StzEngineStringRemoveCharsOfType(pStr, 5)  # remove punct
Assert("RemoveCharsOfType punct", StzEngineStringData(pRem), "Hello 123")
StzEngineStringFree(pRem)
StzEngineStringFree(pStr)

pStr = StzEngineString("  hello  ")
pTrimmed = StzEngineStringTrim(pStr)
Assert("Trim", StzEngineStringData(pTrimmed), "hello")
StzEngineStringFree(pTrimmed)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pTrimmed = StzEngineStringTrim(pStr)
Assert("Trim no-op", StzEngineStringData(pTrimmed), "hello")
StzEngineStringFree(pTrimmed)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello World")
pSwapped = StzEngineStringSwapCase(pStr)
Assert("SwapCase", StzEngineStringData(pSwapped), "hELLO wORLD")
StzEngineStringFree(pSwapped)
StzEngineStringFree(pStr)

pStr = StzEngineString("123")
pSwapped = StzEngineStringSwapCase(pStr)
Assert("SwapCase digits", StzEngineStringData(pSwapped), "123")
StzEngineStringFree(pSwapped)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 28: UniqueChars, UniqueCharsCount
# ==============================================================

? NL + "--- Group 28: UniqueChars, UniqueCharsCount ---"

pStr = StzEngineString("aabbcc")
pUniq = StzEngineStringUniqueChars(pStr)
Assert("UniqueChars aabbcc", StzEngineStringData(pUniq), "abc")
StzEngineStringFree(pUniq)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello")
pUniq = StzEngineStringUniqueChars(pStr)
Assert("UniqueChars Hello", StzEngineStringData(pUniq), "Helo")
StzEngineStringFree(pUniq)

Assert("UniqueCharsCount Hello", StzEngineStringUniqueCharsCount(pStr), 4)
StzEngineStringFree(pStr)

pStr = StzEngineString("abcabc")
Assert("UniqueCharsCount abcabc", StzEngineStringUniqueCharsCount(pStr), 3)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 29: RemoveAllCI
# ==============================================================

? NL + "--- Group 29: RemoveAllCI ---"

pStr = StzEngineString("Hello HELLO hello world")
pResult = StzEngineStringRemoveAllCI(pStr, "hello")
Assert("RemoveAllCI", StzEngineStringData(pResult), "   world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 30: IsAlphaOnly, IsAlnum
# ==============================================================

? NL + "--- Group 30: IsAlphaOnly, IsAlnum ---"

pStr = StzEngineString("Hello")
Assert("IsAlphaOnly yes", StzEngineStringIsAlphaOnly(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello123")
Assert("IsAlphaOnly no", StzEngineStringIsAlphaOnly(pStr), 0)
Assert("IsAlnum yes", StzEngineStringIsAlnum(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello 123")
Assert("IsAlnum no (space)", StzEngineStringIsAlnum(pStr), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 31: ContainsChar
# ==============================================================

? NL + "--- Group 31: ContainsChar ---"

pStr = StzEngineString("Hello")
Assert("ContainsChar H", StzEngineStringContainsChar(pStr, 72), 1)
Assert("ContainsChar o", StzEngineStringContainsChar(pStr, 111), 1)
Assert("ContainsChar Z", StzEngineStringContainsChar(pStr, 90), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 32: BetweenNth, CountBetween
# ==============================================================

? NL + "--- Group 32: BetweenNth, CountBetween ---"

pStr = StzEngineString("[a] [b] [c]")
Assert("CountBetween", StzEngineStringCountBetween(pStr, "[", "]"), 3)

pR0 = StzEngineStringBetweenNth(pStr, "[", "]", 0)
Assert("BetweenNth 0", StzEngineStringData(pR0), "a")
StzEngineStringFree(pR0)

pR1 = StzEngineStringBetweenNth(pStr, "[", "]", 1)
Assert("BetweenNth 1", StzEngineStringData(pR1), "b")
StzEngineStringFree(pR1)

pR2 = StzEngineStringBetweenNth(pStr, "[", "]", 2)
Assert("BetweenNth 2", StzEngineStringData(pR2), "c")
StzEngineStringFree(pR2)

StzEngineStringFree(pStr)

pStr = StzEngineString("no brackets")
Assert("CountBetween none", StzEngineStringCountBetween(pStr, "[", "]"), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 33: ReplaceCharAt
# ==============================================================

? NL + "--- Group 33: ReplaceCharAt ---"

pStr = StzEngineString("Hello")
pR = StzEngineStringReplaceCharAt(pStr, 1, "J")
Assert("ReplaceCharAt 0->J", StzEngineStringData(pR), "Jello")
StzEngineStringFree(pR)

pR2 = StzEngineStringReplaceCharAt(pStr, 5, "!")
Assert("ReplaceCharAt 4->!", StzEngineStringData(pR2), "Hell!")
StzEngineStringFree(pR2)

StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 34: LevenshteinDistance
# ==============================================================

? NL + "--- Group 34: LevenshteinDistance ---"

pS1 = StzEngineString("kitten")
pS2 = StzEngineString("sitting")
Assert("Levenshtein kitten/sitting", StzEngineStringLevenshteinDistance(pS1, pS2), 3)
StzEngineStringFree(pS1)
StzEngineStringFree(pS2)

pS1 = StzEngineString("hello")
pS2 = StzEngineString("hello")
Assert("Levenshtein same", StzEngineStringLevenshteinDistance(pS1, pS2), 0)
StzEngineStringFree(pS1)
StzEngineStringFree(pS2)

pS1 = StzEngineString("")
pS2 = StzEngineString("abc")
Assert("Levenshtein empty/abc", StzEngineStringLevenshteinDistance(pS1, pS2), 3)
StzEngineStringFree(pS1)
StzEngineStringFree(pS2)

# ==============================================================
#  GROUP 35: IsTitleCase
# ==============================================================

? NL + "--- Group 35: IsTitleCase ---"

pStr = StzEngineString("Hello World")
Assert("IsTitleCase yes", StzEngineStringIsTitleCase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
Assert("IsTitleCase no", StzEngineStringIsTitleCase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("HELLO")
Assert("IsTitleCase HELLO no", StzEngineStringIsTitleCase(pStr), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 36: LinesSplitCount, LineAt
# ==============================================================

? NL + "--- Group 36: LinesSplitCount, LineAt ---"

pStr = StzEngineString("line1" + char(10) + "line2" + char(10) + "line3")
Assert("LinesSplitCount 3", StzEngineStringLinesSplitCount(pStr), 3)

pL0 = StzEngineStringLineAt(pStr, 0)
Assert("LineAt 0", StzEngineStringData(pL0), "line1")
StzEngineStringFree(pL0)

pL1 = StzEngineStringLineAt(pStr, 1)
Assert("LineAt 1", StzEngineStringData(pL1), "line2")
StzEngineStringFree(pL1)

pL2 = StzEngineStringLineAt(pStr, 2)
Assert("LineAt 2", StzEngineStringData(pL2), "line3")
StzEngineStringFree(pL2)

StzEngineStringFree(pStr)

pStr = StzEngineString("single line")
Assert("LinesSplitCount 1", StzEngineStringLinesSplitCount(pStr), 1)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 37: Simplify
# ==============================================================

? NL + "--- Group 37: Simplify ---"

pStr = StzEngineString("  hello   world  ")
pR = StzEngineStringSimplify(pStr)
Assert("Simplify spaces", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString(char(9) + "hello" + char(10) + char(10) + "  world" + char(13) + char(10))
pR = StzEngineStringSimplify(pStr)
Assert("Simplify tabs/nl", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 38: StartsWithLetter/Digit, EndsWithLetter/Digit
# ==============================================================

? NL + "--- Group 38: StartsWithLetter/Digit, EndsWithLetter/Digit ---"

pStr = StzEngineString("Hello123")
Assert("StartsWithLetter yes", StzEngineStringStartsWithLetter(pStr), 1)
Assert("StartsWithDigit no", StzEngineStringStartsWithDigit(pStr), 0)
Assert("EndsWithDigit yes", StzEngineStringEndsWithDigit(pStr), 1)
Assert("EndsWithLetter no", StzEngineStringEndsWithLetter(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("123Hello")
Assert("StartsWithDigit yes", StzEngineStringStartsWithDigit(pStr), 1)
Assert("StartsWithLetter no", StzEngineStringStartsWithLetter(pStr), 0)
Assert("EndsWithLetter yes", StzEngineStringEndsWithLetter(pStr), 1)
Assert("EndsWithDigit no", StzEngineStringEndsWithDigit(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 39: IsWord ---
? NL + "--- Group 39: IsWord ---"
pStr = StzEngineString("hello-world_123", 15)
Assert("IsWord yes", StzEngineStringIsWord(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world", 11)
Assert("IsWord no (space)", StzEngineStringIsWord(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello!", 6)
Assert("IsWord no (punct)", StzEngineStringIsWord(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("", 0)
Assert("IsWord empty", StzEngineStringIsWord(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 40: CountLeadingChar, CountTrailingChar ---
? NL + "--- Group 40: CountLeadingChar, CountTrailingChar ---"
pStr = StzEngineString("   hello", 8)
Assert("CountLeadingChar 3 spaces", StzEngineStringCountLeadingChar(pStr, 32), 3)
Assert("CountTrailingChar 0 spaces", StzEngineStringCountTrailingChar(pStr, 32), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello...", 8)
Assert("CountLeadingChar 0 dots", StzEngineStringCountLeadingChar(pStr, 46), 0)
Assert("CountTrailingChar 3 dots", StzEngineStringCountTrailingChar(pStr, 46), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("aaabbb", 6)
Assert("CountLeadingChar 3 a's", StzEngineStringCountLeadingChar(pStr, 97), 3)
Assert("CountTrailingChar 3 b's", StzEngineStringCountTrailingChar(pStr, 98), 3)
StzEngineStringFree(pStr)

# --- Group 41: IsNumericString ---
? NL + "--- Group 41: IsNumericString ---"
pStr = StzEngineString("12345", 5)
Assert("IsNumericString digits", StzEngineStringIsNumericString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("+42", 3)
Assert("IsNumericString +42", StzEngineStringIsNumericString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("-7", 2)
Assert("IsNumericString -7", StzEngineStringIsNumericString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("12.5", 4)
Assert("IsNumericString no (dot)", StzEngineStringIsNumericString(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc", 3)
Assert("IsNumericString no (letters)", StzEngineStringIsNumericString(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 42: URLEncode, URLDecode ---
? NL + "--- Group 42: URLEncode, URLDecode ---"
pStr = StzEngineString("hello world", 11)
pEnc = StzEngineStringURLEncode(pStr)
Assert("URLEncode spaces", StzEngineStringData(pEnc), "hello%20world")
pDec = StzEngineStringURLDecode(pEnc)
Assert("URLDecode roundtrip", StzEngineStringData(pDec), "hello world")
StzEngineStringFree(pDec)
StzEngineStringFree(pEnc)
StzEngineStringFree(pStr)

pStr = StzEngineString("a+b=c&d", 7)
pEnc = StzEngineStringURLEncode(pStr)
Assert("URLEncode special", StzEngineStringData(pEnc), "a%2Bb%3Dc%26d")
StzEngineStringFree(pEnc)
StzEngineStringFree(pStr)

# --- Group 43: CharAtToString ---
? NL + "--- Group 43: CharAtToString ---"
pStr = StzEngineString("Hello", 5)
pCh = StzEngineStringCharAtToString(pStr, 1)
Assert("CharAtToString 0=H", StzEngineStringData(pCh), "H")
StzEngineStringFree(pCh)
pCh = StzEngineStringCharAtToString(pStr, 5)
Assert("CharAtToString 4=o", StzEngineStringData(pCh), "o")
StzEngineStringFree(pCh)
StzEngineStringFree(pStr)

# --- Group 44: Spacify ---
? NL + "--- Group 44: Spacify ---"
pStr = StzEngineString("abc", 3)
pR = StzEngineStringSpacify(pStr)
Assert("Spacify abc", StzEngineStringData(pR), "a b c")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("X", 1)
pR = StzEngineStringSpacify(pStr)
Assert("Spacify single", StzEngineStringData(pR), "X")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 45: BytesPerChar ---
? NL + "--- Group 45: BytesPerChar ---"
pStr = StzEngineString("ab", 2)
pR = StzEngineStringBytesPerChar(pStr)
Assert("BytesPerChar ASCII", StzEngineStringData(pR), "1 1")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 46: IsHexString, IsBinaryString, IsOctalString ---
? NL + "--- Group 46: IsHexString, IsBinaryString, IsOctalString ---"
pStr = StzEngineString("0xFF", 4)
Assert("IsHexString 0xFF", StzEngineStringIsHexString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("deadBEEF", 8)
Assert("IsHexString deadBEEF", StzEngineStringIsHexString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("GHIJ", 4)
Assert("IsHexString no", StzEngineStringIsHexString(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("0b1010", 6)
Assert("IsBinaryString 0b1010", StzEngineStringIsBinaryString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("1100", 4)
Assert("IsBinaryString 1100", StzEngineStringIsBinaryString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("1020", 4)
Assert("IsBinaryString no", StzEngineStringIsBinaryString(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("0o777", 5)
Assert("IsOctalString 0o777", StzEngineStringIsOctalString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("0o89", 4)
Assert("IsOctalString no", StzEngineStringIsOctalString(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 47: WordAt ---
? NL + "--- Group 47: WordAt ---"
pStr = StzEngineString("hello world foo", 15)
pW = StzEngineStringWordAt(pStr, 0)
Assert("WordAt 0", StzEngineStringData(pW), "hello")
StzEngineStringFree(pW)
pW = StzEngineStringWordAt(pStr, 1)
Assert("WordAt 1", StzEngineStringData(pW), "world")
StzEngineStringFree(pW)
pW = StzEngineStringWordAt(pStr, 2)
Assert("WordAt 2", StzEngineStringData(pW), "foo")
StzEngineStringFree(pW)
StzEngineStringFree(pStr)

# --- Group 48: Center ---
? NL + "--- Group 48: Center ---"
pStr = StzEngineString("hi", 2)
pR = StzEngineStringCenter(pStr, 6, 32)
Assert("Center hi in 6", StzEngineStringData(pR), "  hi  ")
StzEngineStringFree(pR)
pR = StzEngineStringCenter(pStr, 7, 32)
Assert("Center hi in 7", StzEngineStringData(pR), "  hi   ")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 49: RemoveConsecutiveDuplicates ---
? NL + "--- Group 49: RemoveConsecutiveDuplicates ---"
pStr = StzEngineString("aabbcc", 6)
pR = StzEngineStringRemoveConsecutiveDuplicates(pStr)
Assert("RemoveConsecDups aabbcc", StzEngineStringData(pR), "abc")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("mississippi", 11)
pR = StzEngineStringRemoveConsecutiveDuplicates(pStr)
Assert("RemoveConsecDups mississippi", StzEngineStringData(pR), "misisipi")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello", 5)
pR = StzEngineStringRemoveConsecutiveDuplicates(pStr)
Assert("RemoveConsecDups hello", StzEngineStringData(pR), "helo")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 50: Substring ---
? NL + "--- Group 50: Substring ---"
pStr = StzEngineString("Hello World", 11)
pSub = StzEngineStringSubstring(pStr, 1, 5)
Assert("Substring 0-4", StzEngineStringData(pSub), "Hello")
StzEngineStringFree(pSub)
pSub = StzEngineStringSubstring(pStr, 7, 11)
Assert("Substring 6-10", StzEngineStringData(pSub), "World")
StzEngineStringFree(pSub)
StzEngineStringFree(pStr)

# --- Group 51: ReplaceSubstring ---
? NL + "--- Group 51: ReplaceSubstring ---"
pStr = StzEngineString("Hello World", 11)
pR = StzEngineStringReplaceSubstring(pStr, 7, 11, "Zig", 3)
Assert("ReplaceSubstring", StzEngineStringData(pR), "Hello Zig")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 52: PrefixCount, SuffixCount ---
? NL + "--- Group 52: PrefixCount, SuffixCount ---"
pStr = StzEngineString("ababab", 6)
Assert("PrefixCount ab", StzEngineStringPrefixCount(pStr, "ab"), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("xyzxyzxyz", 9)
Assert("SuffixCount xyz", StzEngineStringSuffixCount(pStr, "xyz"), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello", 5)
Assert("PrefixCount h", StzEngineStringPrefixCount(pStr, "h"), 1)
Assert("SuffixCount o", StzEngineStringSuffixCount(pStr, "o"), 1)
StzEngineStringFree(pStr)

# --- Group 53: CommonPrefix, CommonSuffix ---
? NL + "--- Group 53: CommonPrefix, CommonSuffix ---"
pStr1 = StzEngineString("hello world", 11)
pStr2 = StzEngineString("hello there", 11)
pCP = StzEngineStringCommonPrefix(pStr1, pStr2)
Assert("CommonPrefix", StzEngineStringData(pCP), "hello ")
StzEngineStringFree(pCP)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr1 = StzEngineString("testing", 7)
pStr2 = StzEngineString("working", 7)
pCS = StzEngineStringCommonSuffix(pStr1, pStr2)
Assert("CommonSuffix", StzEngineStringData(pCS), "ing")
StzEngineStringFree(pCS)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

# --- Group 54: SortCharsAsc, SortCharsDesc ---
? NL + "--- Group 54: SortCharsAsc, SortCharsDesc ---"
pStr = StzEngineString("dcba")
pR = StzEngineStringSortCharsAsc(pStr)
Assert("SortCharsAsc dcba", StzEngineStringData(pR), "abcd")
StzEngineStringFree(pR)
pR = StzEngineStringSortCharsDesc(pStr)
Assert("SortCharsDesc dcba", StzEngineStringData(pR), "dcba")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 55: FindAllChar, Hash, CountChar, ReplaceChar ---
? NL + "--- Group 55: FindAllChar, Hash, CountChar, ReplaceChar ---"
pStr = StzEngineString("abcabc")
pFR = StzEngineStringFindAllChar(pStr, 97)
Assert("FindAllChar a count", StzEngineFindResultCount(pFR), 2)
Assert("FindAllChar a pos0", StzEngineFindResultGet(pFR, 0), 1)
Assert("FindAllChar a pos1", StzEngineFindResultGet(pFR, 1), 4)
StzEngineFindResultFree(pFR)
StzEngineStringFree(pStr)

pStr1 = StzEngineString("hello")
pStr2 = StzEngineString("hello")
Assert("Hash same", StzEngineStringHash(pStr1), StzEngineStringHash(pStr2))
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr = StzEngineString("mississippi")
Assert("CountChar s", StzEngineStringCountChar(pStr, 115), 4)
Assert("CountChar i", StzEngineStringCountChar(pStr, 105), 4)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pR = StzEngineStringReplaceChar(pStr, 108, 114)
Assert("ReplaceChar l->r", StzEngineStringData(pR), "herro")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 56: Copy ---
? NL + "--- Group 56: Copy ---"
pStr = StzEngineString("Hello World")
pCopy = StzEngineStringCopy(pStr)
Assert("Copy data", StzEngineStringData(pCopy), "Hello World")
Assert("Copy size", StzEngineStringSize(pCopy), 11)
StzEngineStringFree(pCopy)
StzEngineStringFree(pStr)

# --- Group 57: Compare ---
? NL + "--- Group 57: Compare ---"
pA = StzEngineString("abc")
pB = StzEngineString("abc")
pC = StzEngineString("abd")
pD = StzEngineString("ab")
Assert("Compare equal", StzEngineStringCompare(pA, pB), 0)
Assert("Compare less", StzEngineStringCompare(pA, pC), -1)
Assert("Compare greater", StzEngineStringCompare(pC, pA), 1)
Assert("Compare shorter", StzEngineStringCompare(pD, pA), -1)
Assert("Compare longer", StzEngineStringCompare(pA, pD), 1)
StzEngineStringFree(pD)
StzEngineStringFree(pC)
StzEngineStringFree(pB)
StzEngineStringFree(pA)

# --- Group 58: RemoveFirst/Last/NthOccurrence ---
? NL + "--- Group 58: RemoveFirst/Last/NthOccurrence ---"
pStr = StzEngineString("hello world hello")
pR = StzEngineStringRemoveFirstOccurrence(pStr, "hello")
Assert("RemoveFirst hello", StzEngineStringData(pR), " world hello")
StzEngineStringFree(pR)
pR = StzEngineStringRemoveLastOccurrence(pStr, "hello")
Assert("RemoveLast hello", StzEngineStringData(pR), "hello world ")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("abcabcabc")
pR = StzEngineStringRemoveNthOccurrence(pStr, "abc", 0)
Assert("RemoveNth 0", StzEngineStringData(pR), "abcabc")
StzEngineStringFree(pR)
pR = StzEngineStringRemoveNthOccurrence(pStr, "abc", 2)
Assert("RemoveNth 2", StzEngineStringData(pR), "abcabc")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 59: IsCharsSortedAsc/Desc ---
? NL + "--- Group 59: IsCharsSortedAsc/Desc ---"
pStr = StzEngineString("abcd")
Assert("SortedAsc abcd", StzEngineStringIsCharsSortedAsc(pStr), 1)
Assert("SortedDesc abcd", StzEngineStringIsCharsSortedDesc(pStr), 0)
StzEngineStringFree(pStr)
pStr = StzEngineString("dcba")
Assert("SortedAsc dcba", StzEngineStringIsCharsSortedAsc(pStr), 0)
Assert("SortedDesc dcba", StzEngineStringIsCharsSortedDesc(pStr), 1)
StzEngineStringFree(pStr)

# --- Group 60: RepeatChar ---
? NL + "--- Group 60: RepeatChar ---"
pR = StzEngineStringRepeatChar(42, 5)
Assert("RepeatChar * x5", StzEngineStringData(pR), "*****")
StzEngineStringFree(pR)

# --- Group 61: InsertBeforeEach, InsertAfterEach ---
? NL + "--- Group 61: InsertBeforeEach, InsertAfterEach ---"
pStr = StzEngineString("abcabc")
pR = StzEngineStringInsertBeforeEach(pStr, "abc", "[")
Assert("InsertBeforeEach", StzEngineStringData(pR), "[abc[abc")
StzEngineStringFree(pR)
pR = StzEngineStringInsertAfterEach(pStr, "abc", "]")
Assert("InsertAfterEach", StzEngineStringData(pR), "abc]abc]")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 62: Truncate ---
? NL + "--- Group 62: Truncate ---"
pStr = StzEngineString("Hello World")
pR = StzEngineStringTruncate(pStr, 5, "...")
Assert("Truncate 5", StzEngineStringData(pR), "Hello...")
StzEngineStringFree(pR)
pR = StzEngineStringTruncate(pStr, 20, "...")
Assert("Truncate no-op", StzEngineStringData(pR), "Hello World")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 63: WrapAt ---
? NL + "--- Group 63: WrapAt ---"
pStr = StzEngineString("hello world foo bar")
pR = StzEngineStringWrapAt(pStr, 10)
Assert("WrapAt 10", StzEngineStringData(pR), "hello" + nl + "world foo" + nl + "bar")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 64: RemovePrefix, RemoveSuffix ---
? NL + "--- Group 64: RemovePrefix, RemoveSuffix ---"
pStr = StzEngineString("Hello World")
pR = StzEngineStringRemovePrefix(pStr, "Hello ")
Assert("RemovePrefix", StzEngineStringData(pR), "World")
StzEngineStringFree(pR)
pR = StzEngineStringRemoveSuffix(pStr, " World")
Assert("RemoveSuffix", StzEngineStringData(pR), "Hello")
StzEngineStringFree(pR)
pR = StzEngineStringRemovePrefix(pStr, "xyz")
Assert("RemovePrefix no-op", StzEngineStringData(pR), "Hello World")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 65: EnsurePrefix, EnsureSuffix ---
? NL + "--- Group 65: EnsurePrefix, EnsureSuffix ---"
pStr = StzEngineString("world")
pR = StzEngineStringEnsurePrefix(pStr, "hello ")
Assert("EnsurePrefix add", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pR = StzEngineStringEnsurePrefix(pStr, "hello")
Assert("EnsurePrefix noop", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
pR = StzEngineStringEnsureSuffix(pStr, ".txt")
Assert("EnsureSuffix add", StzEngineStringData(pR), "hello world.txt")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 66: SqueezeChar ---
? NL + "--- Group 66: SqueezeChar ---"
pStr = StzEngineString("heeellooo")
pR = StzEngineStringSqueezeChar(pStr, 101)
Assert("SqueezeChar e", StzEngineStringData(pR), "hellooo")
StzEngineStringFree(pR)
pR = StzEngineStringSqueezeChar(pStr, 111)
Assert("SqueezeChar o", StzEngineStringData(pR), "heeello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 67: CapitalizeFirst, DecapitalizeFirst ---
? NL + "--- Group 67: CapitalizeFirst, DecapitalizeFirst ---"
pStr = StzEngineString("hello world")
pR = StzEngineStringCapitalizeFirst(pStr)
Assert("CapitalizeFirst", StzEngineStringData(pR), "Hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello")
pR = StzEngineStringDecapitalizeFirst(pStr)
Assert("DecapitalizeFirst", StzEngineStringData(pR), "hello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 68: ZFill ---
? NL + "--- Group 68: ZFill ---"
pStr = StzEngineString("42")
pR = StzEngineStringZFill(pStr, 5)
Assert("ZFill 42->00042", StzEngineStringData(pR), "00042")
StzEngineStringFree(pR)
pR = StzEngineStringZFill(pStr, 2)
Assert("ZFill no-op", StzEngineStringData(pR), "42")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 69: TabExpand ---
? NL + "--- Group 69: TabExpand ---"
pStr = StzEngineString("a" + char(9) + "b")
pR = StzEngineStringTabExpand(pStr, 4)
Assert("TabExpand 4", StzEngineStringData(pR), "a    b")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 70: CountOverlapping ---
? NL + "--- Group 70: CountOverlapping ---"
pStr = StzEngineString("aaaa")
Assert("CountOverlapping aa in aaaa", StzEngineStringCountOverlapping(pStr, "aa"), 3)
StzEngineStringFree(pStr)
pStr = StzEngineString("abcabc")
Assert("CountOverlapping abc", StzEngineStringCountOverlapping(pStr, "abc"), 2)
StzEngineStringFree(pStr)

# --- Group 71: ReplaceAt ---
? NL + "--- Group 71: ReplaceAt ---"
pStr = StzEngineString("Hello World")
pR = StzEngineStringReplaceAt(pStr, 6, 1, "-")
Assert("ReplaceAt space->dash", StzEngineStringData(pR), "Hello-World")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 72: CharFrequency ---
? NL + "--- Group 72: CharFrequency ---"
pStr = StzEngineString("aab")
pR = StzEngineStringCharFrequency(pStr)
cFreq = StzEngineStringData(pR)
Assert("CharFrequency contains a:2", substr(cFreq, "a:2") > 0, true)
Assert("CharFrequency contains b:1", substr(cFreq, "b:1") > 0, true)
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 73: ContainsAnyOf, ContainsAllOf ---
? NL + "--- Group 73: ContainsAnyOf, ContainsAllOf ---"
pStr = StzEngineString("hello")
Assert("ContainsAnyOf vowels", StzEngineStringContainsAnyOf(pStr, "aeiou"), 1)
Assert("ContainsAnyOf xyz", StzEngineStringContainsAnyOf(pStr, "xyz"), 0)
Assert("ContainsAllOf helo", StzEngineStringContainsAllOf(pStr, "helo"), 1)
Assert("ContainsAllOf heloz", StzEngineStringContainsAllOf(pStr, "heloz"), 0)
StzEngineStringFree(pStr)

# --- Group 74: Foldcase ---
? NL + "--- Group 74: Foldcase ---"
pStr = StzEngineString("Hello WORLD")
pR = StzEngineStringFoldcase(pStr)
Assert("Foldcase Hello WORLD", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 75: CenterPad ---
? NL + "--- Group 75: CenterPad ---"
pStr = StzEngineString("hi")
pR = StzEngineStringCenterPad(pStr, 6, "-")
Assert("CenterPad hi to 6 with -", StzEngineStringData(pR), "--hi--")
StzEngineStringFree(pR)
pR2 = StzEngineStringCenterPad(pStr, 7, "*")
Assert("CenterPad hi to 7 with *", StzEngineStringData(pR2), "**hi***")
StzEngineStringFree(pR2)
StzEngineStringFree(pStr)

# --- Group 76: OnlyLetters, OnlyDigits ---
? NL + "--- Group 76: OnlyLetters, OnlyDigits ---"
pStr = StzEngineString("h3ll0 w0rld!")
pR = StzEngineStringOnlyLetters(pStr)
Assert("OnlyLetters from h3ll0 w0rld!", StzEngineStringData(pR), "hllwrld")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("a1b2c3")
pR = StzEngineStringOnlyDigits(pStr)
Assert("OnlyDigits from a1b2c3", StzEngineStringData(pR), "123")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 77: RemoveWhitespace ---
? NL + "--- Group 77: RemoveWhitespace ---"
pStr = StzEngineString("h e l l o")
pR = StzEngineStringRemoveWhitespace(pStr)
Assert("RemoveWhitespace", StzEngineStringData(pR), "hello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 78: CountWords, NthWord ---
? NL + "--- Group 78: CountWords, NthWord ---"
pStr = StzEngineString("hello world foo")
Assert("CountWords 3", StzEngineStringCountWords(pStr), 3)
pW = StzEngineStringNthWord(pStr, 0)
Assert("NthWord 0 = hello", StzEngineStringData(pW), "hello")
StzEngineStringFree(pW)
pW = StzEngineStringNthWord(pStr, 1)
Assert("NthWord 1 = world", StzEngineStringData(pW), "world")
StzEngineStringFree(pW)
pW = StzEngineStringNthWord(pStr, 2)
Assert("NthWord 2 = foo", StzEngineStringData(pW), "foo")
StzEngineStringFree(pW)
StzEngineStringFree(pStr)

pStr = StzEngineString("  hello  ")
Assert("CountWords leading/trailing spaces", StzEngineStringCountWords(pStr), 1)
StzEngineStringFree(pStr)

# --- Group 79: CharsBetween ---
? NL + "--- Group 79: CharsBetween ---"
pStr = StzEngineString("abcdef")
pR = StzEngineStringCharsBetween(pStr, 2, 5)
Assert("CharsBetween 1..4 = cd", StzEngineStringData(pR), "cd")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 80: IsAlphanumeric ---
? NL + "--- Group 80: IsAlphanumeric ---"
pStr = StzEngineString("hello123")
Assert("IsAlphanumeric hello123", StzEngineStringIsAlphanumeric(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello 123")
Assert("IsAlphanumeric with space", StzEngineStringIsAlphanumeric(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello!")
Assert("IsAlphanumeric with punct", StzEngineStringIsAlphanumeric(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 81: Ljust, Rjust ---
? NL + "--- Group 81: Ljust, Rjust ---"
pStr = StzEngineString("hi")
pR = StzEngineStringLjust(pStr, 5, ".")
Assert("Ljust hi to 5 with .", StzEngineStringData(pR), "hi...")
StzEngineStringFree(pR)

pR = StzEngineStringRjust(pStr, 5, ".")
Assert("Rjust hi to 5 with .", StzEngineStringData(pR), "...hi")
StzEngineStringFree(pR)

pR = StzEngineStringLjust(pStr, 2, ".")
Assert("Ljust no pad needed", StzEngineStringData(pR), "hi")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 82: Indent, Dedent ---
? NL + "--- Group 82: Indent, Dedent ---"
pStr = StzEngineString("line1" + char(10) + "line2")
pR = StzEngineStringIndent(pStr, 4)
cIndented = StzEngineStringData(pR)
Assert("Indent starts with spaces", left(cIndented, 4), "    ")
Assert("Indent contains indented line2", substr(cIndented, "    line2") > 0, true)
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("    hello" + char(10) + "    world")
pR = StzEngineStringDedent(pStr)
cDedented = StzEngineStringData(pR)
Assert("Dedent removes common indent", left(cDedented, 5), "hello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 83: CamelCase, SnakeCase, KebabCase ---
? NL + "--- Group 83: CamelCase, SnakeCase, KebabCase ---"
pStr = StzEngineString("hello world")
pR = StzEngineStringToCamelCase(pStr)
Assert("CamelCase hello world", StzEngineStringData(pR), "helloWorld")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("helloWorld")
pR = StzEngineStringToSnakeCase(pStr)
Assert("SnakeCase helloWorld", StzEngineStringData(pR), "hello_world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello_world")
pR = StzEngineStringToKebabCase(pStr)
Assert("KebabCase hello_world", StzEngineStringData(pR), "hello-world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("MyClassName")
pR = StzEngineStringToSnakeCase(pStr)
Assert("SnakeCase MyClassName", StzEngineStringData(pR), "my_class_name")
StzEngineStringFree(pR)

pR = StzEngineStringToKebabCase(pStr)
Assert("KebabCase MyClassName", StzEngineStringData(pR), "my-class-name")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 84: Partition, RPartition
# ==============================================================

? NL + "--- Group 84: Partition/RPartition ---"

pStr = StzEngineString("hello:world:foo")
pBefore = StzEngineStringPartition(pStr, ":")
Assert("Partition before", StzEngineStringData(pBefore), "hello")
StzEngineStringFree(pBefore)

pAfter = StzEngineStringPartitionAfter(pStr, ":")
Assert("Partition after", StzEngineStringData(pAfter), "world:foo")
StzEngineStringFree(pAfter)

pRBefore = StzEngineStringRpartition(pStr, ":")
Assert("RPartition before", StzEngineStringData(pRBefore), "hello:world")
StzEngineStringFree(pRBefore)

pRAfter = StzEngineStringRpartitionAfter(pStr, ":")
Assert("RPartition after", StzEngineStringData(pRAfter), "foo")
StzEngineStringFree(pRAfter)

# Not found case
pBefore2 = StzEngineStringPartition(pStr, "xyz")
Assert("Partition not found returns full", StzEngineStringData(pBefore2), "hello:world:foo")
StzEngineStringFree(pBefore2)

pAfter2 = StzEngineStringPartitionAfter(pStr, "xyz")
Assert("Partition after not found returns empty", StzEngineStringData(pAfter2), "")
StzEngineStringFree(pAfter2)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 85: Squeeze, IsDigit, Interleave
# ==============================================================

? NL + "--- Group 85: Squeeze/IsDigit/Interleave ---"

pStr = StzEngineString("heeellooo")
pR = StzEngineStringSqueeze(pStr)
Assert("Squeeze heeellooo", StzEngineStringData(pR), "helo")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("aabbcc")
pR = StzEngineStringSqueeze(pStr)
Assert("Squeeze aabbcc", StzEngineStringData(pR), "abc")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("12345")
Assert("IsDigit 12345", StzEngineStringIsDigit(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("123a5")
Assert("IsDigit 123a5", StzEngineStringIsDigit(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("")
Assert("IsDigit empty", StzEngineStringIsDigit(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
pR = StzEngineStringInterleave(pStr, ",")
Assert("Interleave abc with comma", StzEngineStringData(pR), "a,b,c")
StzEngineStringFree(pR)

pR = StzEngineStringInterleave(pStr, " - ")
Assert("Interleave abc with dash", StzEngineStringData(pR), "a - b - c")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 86: StripChars, KeepChars, Replace2
# ==============================================================

? NL + "--- Group 86: StripChars/KeepChars/Replace2 ---"

pStr = StzEngineString("hello world!")
pR = StzEngineStringStripChars(pStr, "lo")
Assert("StripChars remove lo", StzEngineStringData(pR), "he wrd!")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("programming")
pR = StzEngineStringStripChars(pStr, "aeiou")
Assert("StripChars vowels", StzEngineStringData(pR), "prgrmmng")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world!")
pR = StzEngineStringKeepChars(pStr, "lo")
Assert("KeepChars lo", StzEngineStringData(pR), "llool")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pR = StzEngineStringReplace2(pStr, "hello", "hi", "world", "earth")
Assert("Replace2 two subs", StzEngineStringData(pR), "hi earth")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 87: Surround, ReplaceAnyChar, CountAnyChar
# ==============================================================

? NL + "--- Group 87: Surround/ReplaceAnyChar/CountAnyChar ---"

pStr = StzEngineString("hello")
pR = StzEngineStringSurround(pStr, "[", "]")
Assert("Surround hello", StzEngineStringData(pR), "[hello]")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pR = StzEngineStringSurround(pStr, "<<", ">>")
Assert("Surround hello <<>>", StzEngineStringData(pR), "<<hello>>")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pR = StzEngineStringReplaceAnyChar(pStr, "lo", "*")
Assert("ReplaceAnyChar lo->*", StzEngineStringData(pR), "he***")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world!")
Assert("CountAnyChar aeiou", StzEngineStringCountAnyChar(pStr, "aeiou"), 3)
Assert("CountAnyChar lo", StzEngineStringCountAnyChar(pStr, "lo"), 5)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 88: Rotate / RepeatToLength / RemoveBetween / IsBlank / ToPascalCase
# ==============================================================


? NL + "--- Group 88: Rotate / RepeatToLength / RemoveBetween / IsBlank / ToPascalCase ---"

pStr = StzEngineString("abcde")
pR = StzEngineStringRotate(pStr, 2)
Assert("Rotate left 2", StzEngineStringData(pR), "cdeab")
StzEngineStringFree(pR)
pR = StzEngineStringRotate(pStr, -1)
Assert("Rotate right 1", StzEngineStringData(pR), "eabcd")
StzEngineStringFree(pR)
pR = StzEngineStringRotate(pStr, 5)
Assert("Rotate by length=noop", StzEngineStringData(pR), "abcde")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
pR = StzEngineStringRepeatToLength(pStr, 7)
Assert("RepeatToLength 7", StzEngineStringData(pR), "abcabca")
StzEngineStringFree(pR)
pR = StzEngineStringRepeatToLength(pStr, 1)
Assert("RepeatToLength 1", StzEngineStringData(pR), "a")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello [world] end")
pR = StzEngineStringRemoveBetween(pStr, "[", "]")
Assert("RemoveBetween []", StzEngineStringData(pR), "hello  end")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("   ")
Assert("IsBlank spaces", StzEngineStringIsBlank(pStr), 1)
StzEngineStringFree(pStr)
pStr = StzEngineString("")
Assert("IsBlank empty", StzEngineStringIsBlank(pStr), 1)
StzEngineStringFree(pStr)
pStr = StzEngineString(" a ")
Assert("IsBlank not blank", StzEngineStringIsBlank(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello_world")
pR = StzEngineStringToPascalCase(pStr)
Assert("ToPascalCase snake", StzEngineStringData(pR), "HelloWorld")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)
pStr = StzEngineString("my-kebab-case")
pR = StzEngineStringToPascalCase(pStr)
Assert("ToPascalCase kebab", StzEngineStringData(pR), "MyKebabCase")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 89: IsIdentifier / ReplaceBetween / ContainsOnly / CapitalizeWords / SwapChars
# ==============================================================


? NL + "--- Group 89: IsIdentifier / ReplaceBetween / ContainsOnly / CapitalizeWords / SwapChars ---"

pStr = StzEngineString("hello_world")
Assert("IsIdentifier valid", StzEngineStringIsIdentifier(pStr), 1)
StzEngineStringFree(pStr)
pStr = StzEngineString("_private")
Assert("IsIdentifier underscore start", StzEngineStringIsIdentifier(pStr), 1)
StzEngineStringFree(pStr)
pStr = StzEngineString("3invalid")
Assert("IsIdentifier digit start", StzEngineStringIsIdentifier(pStr), 0)
StzEngineStringFree(pStr)
pStr = StzEngineString("has space")
Assert("IsIdentifier space", StzEngineStringIsIdentifier(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello [world] end")
pR = StzEngineStringReplaceBetween(pStr, "[", "]", "REPLACED")
Assert("ReplaceBetween []", StzEngineStringData(pR), "hello REPLACED end")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("aabbcc")
Assert("ContainsOnly abc", StzEngineStringContainsOnly(pStr, "abc"), 1)
Assert("ContainsOnly ab", StzEngineStringContainsOnly(pStr, "ab"), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pR = StzEngineStringCapitalizeWords(pStr)
Assert("CapitalizeWords", StzEngineStringData(pR), "Hello World")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("abcde")
pR = StzEngineStringSwapChars(pStr, 1, 5)
Assert("SwapChars 0,4", StzEngineStringData(pR), "ebcda")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 90: EncodeHex / DecodeHex / ReverseWords / CollapseSpaces
# ==============================================================


? NL + "--- Group 90: EncodeHex / DecodeHex / ReverseWords / CollapseSpaces ---"

pStr = StzEngineString("Hi")
pR = StzEngineStringEncodeHex(pStr)
Assert("EncodeHex Hi", StzEngineStringData(pR), "4869")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("4869")
pR = StzEngineStringDecodeHex(pStr)
Assert("DecodeHex 4869", StzEngineStringData(pR), "Hi")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world foo")
pR = StzEngineStringReverseWords(pStr)
Assert("ReverseWords", StzEngineStringData(pR), "foo world hello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("  hello   world  ")
pR = StzEngineStringCollapseSpaces(pStr)
Assert("CollapseSpaces", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 91: IsAnagram / Mask / CountRuns / HammingDistance
# ==============================================================


? NL + "--- Group 91: IsAnagram / Mask / CountRuns / HammingDistance ---"

pStr1 = StzEngineString("listen")
pStr2 = StzEngineString("silent")
Assert("IsAnagram listen/silent", StzEngineStringIsAnagram(pStr1, pStr2), 1)
StzEngineStringFree(pStr2)
pStr2 = StzEngineString("hello")
Assert("IsAnagram listen/hello", StzEngineStringIsAnagram(pStr1, pStr2), 0)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr = StzEngineString("hello@mail.com")
pR = StzEngineStringMask(pStr, "*", 2)
Assert("Mask keep 2", StzEngineStringData(pR), "he**********om")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineString("aabbbcc")
Assert("CountRuns aabbbcc", StzEngineStringCountRuns(pStr), 3)
StzEngineStringFree(pStr)

pStr1 = StzEngineString("karolin")
pStr2 = StzEngineString("kathrin")
Assert("HammingDistance", StzEngineStringHammingDistance(pStr1, pStr2), 3)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

# ==============================================================
#  GROUP 92: RemoveVowels / OnlyVowels / IsPangram / Ngram / NgramCount
# ==============================================================


? NL + "--- Group 92: RemoveVowels / OnlyVowels / IsPangram / Ngram / NgramCount ---"

pStr = StzEngineString("Hello World")
pResult = StzEngineStringRemoveVowels(pStr)
Assert("RemoveVowels Hello World", StzEngineStringData(pResult), "Hll Wrld")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello World")
pResult = StzEngineStringOnlyVowels(pStr)
Assert("OnlyVowels Hello World", StzEngineStringData(pResult), "eoo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("The quick brown fox jumps over the lazy dog")
Assert("IsPangram true", StzEngineStringIsPangram(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello World")
Assert("IsPangram false", StzEngineStringIsPangram(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pResult = StzEngineStringNgram(pStr, 2, 0)
Assert("Ngram(hello,2,0)", StzEngineStringData(pResult), "he")
StzEngineStringFree(pResult)
pResult = StzEngineStringNgram(pStr, 2, 3)
Assert("Ngram(hello,2,3)", StzEngineStringData(pResult), "lo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
Assert("NgramCount(hello,2)", StzEngineStringNgramCount(pStr, 2), 4)
Assert("NgramCount(hello,3)", StzEngineStringNgramCount(pStr, 3), 3)
Assert("NgramCount(hello,5)", StzEngineStringNgramCount(pStr, 5), 1)
Assert("NgramCount(hello,6)", StzEngineStringNgramCount(pStr, 6), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 93: CountConsonants / ToSentenceCase / IsBalanced / Slug / Chunk
# ==============================================================


? NL + "--- Group 93: CountConsonants / ToSentenceCase / IsBalanced / Slug / Chunk ---"

pStr = StzEngineString("Hello World")
Assert("CountConsonants Hello World", StzEngineStringCountConsonants(pStr), 7)
StzEngineStringFree(pStr)

pStr = StzEngineString("hELLO WORLD")
pResult = StzEngineStringToSentenceCase(pStr)
Assert("ToSentenceCase", StzEngineStringData(pResult), "Hello world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("(hello [world])")
Assert("IsBalanced true", StzEngineStringIsBalanced(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("(hello [world)")
Assert("IsBalanced false", StzEngineStringIsBalanced(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello World! This is a Test")
pResult = StzEngineStringSlug(pStr)
Assert("Slug", StzEngineStringData(pResult), "hello-world-this-is-a-test")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("abcdefgh")
pResult = StzEngineStringChunk(pStr, 3, 0)
Assert("Chunk(abcdefgh,3,0)", StzEngineStringData(pResult), "abc")
StzEngineStringFree(pResult)
pResult = StzEngineStringChunk(pStr, 3, 2)
Assert("Chunk(abcdefgh,3,2)", StzEngineStringData(pResult), "gh")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 94: CountVowels / LongestRun / TrimChars / IsEmailLike / CamelToWords
# ==============================================================


? NL + "--- Group 94: CountVowels / LongestRun / TrimChars / IsEmailLike / CamelToWords ---"

pStr = StzEngineString("Hello World")
Assert("CountVowels Hello World", StzEngineStringCountVowels(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("aabbbcccc")
Assert("LongestRun aabbbcccc", StzEngineStringLongestRun(pStr), 4)
StzEngineStringFree(pStr)

pStr = StzEngineString("***hello***")
pResult = StzEngineStringTrimChars(pStr, "*")
Assert("TrimChars ***hello***", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("user@example.com")
Assert("IsEmailLike valid", StzEngineStringIsEmailLike(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("not-an-email")
Assert("IsEmailLike invalid", StzEngineStringIsEmailLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("camelCaseString")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords", StzEngineStringData(pResult), "camel Case String")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 95: Extended Edge-Case Tests
# ==============================================================


? NL + "--- Group 95: Extended Edge-Case Tests ---"

# --- RemoveVowels edge cases ---
pStr = StzEngineString("AEIOU")
pResult = StzEngineStringRemoveVowels(pStr)
Assert("RemoveVowels all-uppercase-vowels", StzEngineStringData(pResult), "")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("bcdfg")
pResult = StzEngineStringRemoveVowels(pStr)
Assert("RemoveVowels no-vowels", StzEngineStringData(pResult), "bcdfg")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- OnlyVowels edge cases ---
pStr = StzEngineString("bcdfg")
pResult = StzEngineStringOnlyVowels(pStr)
Assert("OnlyVowels no-vowels empty", StzEngineStringSize(pResult), 0)
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("AEiOu")
pResult = StzEngineStringOnlyVowels(pStr)
Assert("OnlyVowels mixed case", StzEngineStringData(pResult), "AEiOu")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsPangram edge cases ---
pStr = StzEngineString("abcdefghijklmnopqrstuvwxyz")
Assert("IsPangram lowercase only", StzEngineStringIsPangram(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
Assert("IsPangram uppercase only", StzEngineStringIsPangram(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("abcdefghijklmnopqrstuvwxy")
Assert("IsPangram missing z", StzEngineStringIsPangram(pStr), 0)
StzEngineStringFree(pStr)

# --- Ngram edge cases ---
pStr = StzEngineString("ab")
pResult = StzEngineStringNgram(pStr, 3, 0)
Assert("Ngram too-short returns null", IsNULL(pResult), true)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pResult = StzEngineStringNgram(pStr, 1, 4)
Assert("Ngram single-char last", StzEngineStringData(pResult), "o")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- NgramCount edge cases ---
pStr = StzEngineString("")
Assert("NgramCount empty", StzEngineStringNgramCount(pStr, 2), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("a")
Assert("NgramCount single-char size=1", StzEngineStringNgramCount(pStr, 1), 1)
Assert("NgramCount single-char size=2", StzEngineStringNgramCount(pStr, 2), 0)
StzEngineStringFree(pStr)

# --- CountConsonants edge cases ---
pStr = StzEngineString("aeiou AEIOU")
Assert("CountConsonants no-consonants", StzEngineStringCountConsonants(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("BCDFG")
Assert("CountConsonants uppercase", StzEngineStringCountConsonants(pStr), 5)
StzEngineStringFree(pStr)

pStr = StzEngineString("123!@#")
Assert("CountConsonants non-alpha", StzEngineStringCountConsonants(pStr), 0)
StzEngineStringFree(pStr)

# --- ToSentenceCase edge cases ---
pStr = StzEngineString("")
pResult = StzEngineStringToSentenceCase(pStr)
Assert("ToSentenceCase empty", StzEngineStringSize(pResult), 0)
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("A")
pResult = StzEngineStringToSentenceCase(pStr)
Assert("ToSentenceCase single char", StzEngineStringData(pResult), "A")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("   hello")
pResult = StzEngineStringToSentenceCase(pStr)
Assert("ToSentenceCase leading spaces", StzEngineStringData(pResult), "   Hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsBalanced edge cases ---
pStr = StzEngineString("")
Assert("IsBalanced empty", StzEngineStringIsBalanced(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("no brackets here")
Assert("IsBalanced no brackets", StzEngineStringIsBalanced(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("((()))")
Assert("IsBalanced nested parens", StzEngineStringIsBalanced(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString(")(")
Assert("IsBalanced reversed", StzEngineStringIsBalanced(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("{[}]")
Assert("IsBalanced mismatched", StzEngineStringIsBalanced(pStr), 0)
StzEngineStringFree(pStr)

# --- Slug edge cases ---
pStr = StzEngineString("")
pResult = StzEngineStringSlug(pStr)
Assert("Slug empty", StzEngineStringSize(pResult), 0)
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("already-a-slug")
pResult = StzEngineStringSlug(pStr)
Assert("Slug already-slug", StzEngineStringData(pResult), "already-a-slug")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello_World-Test")
pResult = StzEngineStringSlug(pStr)
Assert("Slug mixed separators", StzEngineStringData(pResult), "hello-world-test")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("  leading trailing  ")
pResult = StzEngineStringSlug(pStr)
Assert("Slug leading/trailing spaces", StzEngineStringData(pResult), "leading-trailing")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- Chunk edge cases ---
pStr = StzEngineString("abcdefgh")
pResult = StzEngineStringChunk(pStr, 3, 1)
Assert("Chunk middle", StzEngineStringData(pResult), "def")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
pResult = StzEngineStringChunk(pStr, 3, 0)
Assert("Chunk exact fit", StzEngineStringData(pResult), "abc")
StzEngineStringFree(pResult)
pResult = StzEngineStringChunk(pStr, 3, 1)
Assert("Chunk past end returns null", IsNULL(pResult), true)
StzEngineStringFree(pStr)

# --- CountVowels edge cases ---
pStr = StzEngineString("")
Assert("CountVowels empty", StzEngineStringCountVowels(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("AeIoU")
Assert("CountVowels mixed case", StzEngineStringCountVowels(pStr), 5)
StzEngineStringFree(pStr)

# --- LongestRun edge cases ---
pStr = StzEngineString("")
Assert("LongestRun empty", StzEngineStringLongestRun(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("aaaaaaa")
Assert("LongestRun all-same", StzEngineStringLongestRun(pStr), 7)
StzEngineStringFree(pStr)

pStr = StzEngineString("a")
Assert("LongestRun single", StzEngineStringLongestRun(pStr), 1)
StzEngineStringFree(pStr)

# --- TrimChars edge cases ---
pStr = StzEngineString("hello")
pResult = StzEngineStringTrimChars(pStr, "*")
Assert("TrimChars nothing to trim", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("***")
pResult = StzEngineStringTrimChars(pStr, "*")
Assert("TrimChars all trimmed", StzEngineStringSize(pResult), 0)
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("--hello--world--")
pResult = StzEngineStringTrimChars(pStr, "-")
Assert("TrimChars hyphens", StzEngineStringData(pResult), "hello--world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsEmailLike edge cases ---
pStr = StzEngineString("a@b.c")
Assert("IsEmailLike minimal valid", StzEngineStringIsEmailLike(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("user@.com")
Assert("IsEmailLike dot at start", StzEngineStringIsEmailLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("user@domain.")
Assert("IsEmailLike dot at end", StzEngineStringIsEmailLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("user@@domain.com")
Assert("IsEmailLike double at", StzEngineStringIsEmailLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("first.last@sub.domain.org")
Assert("IsEmailLike complex valid", StzEngineStringIsEmailLike(pStr), 1)
StzEngineStringFree(pStr)

# --- CamelToWords edge cases ---
pStr = StzEngineString("HTMLParser")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords acronym", StzEngineStringData(pResult), "HTML Parser")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("simple")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords no-camel", StzEngineStringData(pResult), "simple")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("AString")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords PascalCase", StzEngineStringData(pResult), "A String")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("getHTTPSConnection")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords mixed", StzEngineStringData(pResult), "get HTTPS Connection")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- Rotate edge cases ---
pStr = StzEngineString("hello")
pResult = StzEngineStringRotate(pStr, 0)
Assert("Rotate by 0", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pResult = StzEngineStringRotate(pStr, 5)
Assert("Rotate full length", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pResult = StzEngineStringRotate(pStr, -1)
Assert("Rotate right by 1", StzEngineStringData(pResult), "ohell")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- RepeatToLength edge cases ---
pStr = StzEngineString("ab")
pResult = StzEngineStringRepeatToLength(pStr, 5)
Assert("RepeatToLength ab->5", StzEngineStringData(pResult), "ababa")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pResult = StzEngineStringRepeatToLength(pStr, 3)
Assert("RepeatToLength truncate", StzEngineStringData(pResult), "hel")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- RemoveBetween edge cases ---
pStr = StzEngineString("hello (world) there")
pResult = StzEngineStringRemoveBetween(pStr, "(", ")")
Assert("RemoveBetween parens", StzEngineStringData(pResult), "hello  there")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("no delimiters here")
pResult = StzEngineStringRemoveBetween(pStr, "[", "]")
Assert("RemoveBetween no match", StzEngineStringData(pResult), "no delimiters here")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsBlank edge cases ---
pStr = StzEngineString("")
Assert("IsBlank empty", StzEngineStringIsBlank(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("   ")
Assert("IsBlank spaces", StzEngineStringIsBlank(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString(" a ")
Assert("IsBlank with char", StzEngineStringIsBlank(pStr), 0)
StzEngineStringFree(pStr)

# --- ToPascalCase edge cases ---
pStr = StzEngineString("hello world")
pResult = StzEngineStringToPascalCase(pStr)
Assert("ToPascalCase basic", StzEngineStringData(pResult), "HelloWorld")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("one_two_three")
pResult = StzEngineStringToPascalCase(pStr)
Assert("ToPascalCase underscores", StzEngineStringData(pResult), "OneTwoThree")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsIdentifier edge cases ---
pStr = StzEngineString("_private")
Assert("IsIdentifier underscore start", StzEngineStringIsIdentifier(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("123abc")
Assert("IsIdentifier digit start", StzEngineStringIsIdentifier(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("")
Assert("IsIdentifier empty", StzEngineStringIsIdentifier(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("valid_name123")
Assert("IsIdentifier alnum+underscore", StzEngineStringIsIdentifier(pStr), 1)
StzEngineStringFree(pStr)

# --- ReplaceBetween edge cases ---
pStr = StzEngineString("say [hello] friend")
pResult = StzEngineStringReplaceBetween(pStr, "[", "]", "world")
Assert("ReplaceBetween brackets", StzEngineStringData(pResult), "say world friend")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- ContainsOnly edge cases ---
pStr = StzEngineString("0123456789")
Assert("ContainsOnly digits", StzEngineStringContainsOnly(pStr, "0123456789"), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc123")
Assert("ContainsOnly digits fail", StzEngineStringContainsOnly(pStr, "0123456789"), 0)
StzEngineStringFree(pStr)

# --- CapitalizeWords edge cases ---
pStr = StzEngineString("hello world")
pResult = StzEngineStringCapitalizeWords(pStr)
Assert("CapitalizeWords basic", StzEngineStringData(pResult), "Hello World")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("HELLO")
pResult = StzEngineStringCapitalizeWords(pStr)
Assert("CapitalizeWords already upper", StzEngineStringData(pResult), "HELLO")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- SwapChars edge cases ---
pStr = StzEngineString("abcde")
pResult = StzEngineStringSwapChars(pStr, 1, 5)
Assert("SwapChars first/last", StzEngineStringData(pResult), "ebcda")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- EncodeHex / DecodeHex roundtrip ---
pStr = StzEngineString("Hello")
pHex = StzEngineStringEncodeHex(pStr)
Assert("EncodeHex Hello", StzEngineStringData(pHex), "48656c6c6f")
pBack = StzEngineStringDecodeHex(pHex)
Assert("DecodeHex roundtrip", StzEngineStringData(pBack), "Hello")
StzEngineStringFree(pBack)
StzEngineStringFree(pHex)
StzEngineStringFree(pStr)

# --- ReverseWords edge cases ---
pStr = StzEngineString("one")
pResult = StzEngineStringReverseWords(pStr)
Assert("ReverseWords single word", StzEngineStringData(pResult), "one")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("a b c d e")
pResult = StzEngineStringReverseWords(pStr)
Assert("ReverseWords many", StzEngineStringData(pResult), "e d c b a")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- CollapseSpaces edge cases ---
pStr = StzEngineString("   hello   world   ")
pResult = StzEngineStringCollapseSpaces(pStr)
Assert("CollapseSpaces heavy", StzEngineStringData(pResult), "hello world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsAnagram edge cases ---
pStr1 = StzEngineString("listen")
pStr2 = StzEngineString("silent")
Assert("IsAnagram listen/silent", StzEngineStringIsAnagram(pStr1, pStr2), 1)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr1 = StzEngineString("hello")
pStr2 = StzEngineString("world")
Assert("IsAnagram hello/world", StzEngineStringIsAnagram(pStr1, pStr2), 0)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr1 = StzEngineString("abc")
pStr2 = StzEngineString("abcd")
Assert("IsAnagram diff length", StzEngineStringIsAnagram(pStr1, pStr2), 0)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

# --- Mask edge cases ---
pStr = StzEngineString("1234567890")
pResult = StzEngineStringMask(pStr, "*", 4)
Assert("Mask credit-like", StzEngineStringData(pResult), "1234**7890")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("ab")
pResult = StzEngineStringMask(pStr, "#", 4)
Assert("Mask short string", StzEngineStringData(pResult), "ab")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- HammingDistance edge cases ---
pStr1 = StzEngineString("abc")
pStr2 = StzEngineString("abc")
Assert("HammingDistance same", StzEngineStringHammingDistance(pStr1, pStr2), 0)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr1 = StzEngineString("abc")
pStr2 = StzEngineString("xyz")
Assert("HammingDistance all diff", StzEngineStringHammingDistance(pStr1, pStr2), 3)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

# ==============================================================
#  GROUP 96: Initials / RemoveDuplicateWords / IsUrlLike / EscapeHtml / UnescapeHtml
# ==============================================================


? NL + "--- Group 96: Initials / RemoveDuplicateWords / IsUrlLike / EscapeHtml / UnescapeHtml ---"

pStr = StzEngineString("Hello World")
pResult = StzEngineStringInitials(pStr)
Assert("Initials Hello World", StzEngineStringData(pResult), "HW")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("united states of america")
pResult = StzEngineStringInitials(pStr)
Assert("Initials lowercase", StzEngineStringData(pResult), "usoa")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("the the cat sat on the mat")
pResult = StzEngineStringRemoveDuplicateWords(pStr)
Assert("RemoveDuplicateWords", StzEngineStringData(pResult), "the cat sat on mat")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello hello hello")
pResult = StzEngineStringRemoveDuplicateWords(pStr)
Assert("RemoveDuplicateWords all same", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("https://example.com")
Assert("IsUrlLike https", StzEngineStringIsUrlLike(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("http://example.com")
Assert("IsUrlLike http", StzEngineStringIsUrlLike(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("ftp://files.com")
Assert("IsUrlLike ftp", StzEngineStringIsUrlLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("not a url")
Assert("IsUrlLike text", StzEngineStringIsUrlLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("<b>hello</b>")
pResult = StzEngineStringEscapeHtml(pStr)
Assert("EscapeHtml tags", StzEngineStringData(pResult), "&lt;b&gt;hello&lt;/b&gt;")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("a & b")
pResult = StzEngineStringEscapeHtml(pStr)
Assert("EscapeHtml ampersand", StzEngineStringData(pResult), "a &amp; b")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("&lt;b&gt;hello&lt;/b&gt;")
pResult = StzEngineStringUnescapeHtml(pStr)
Assert("UnescapeHtml", StzEngineStringData(pResult), "<b>hello</b>")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("&amp; &quot; &#39;")
pResult = StzEngineStringUnescapeHtml(pStr)
Assert("UnescapeHtml entities", StzEngineStringData(pResult), "& " + char(34) + " '")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 97: CountSentences / TitleSmart / RemovePunctuation / IsFloat / DigitSum
# ==============================================================


? NL + "--- Group 97: CountSentences / TitleSmart / RemovePunctuation / IsFloat / DigitSum ---"

pStr = StzEngineString("Hello. How are you? Fine!")
Assert("CountSentences 3", StzEngineStringCountSentences(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("No sentence end")
Assert("CountSentences 0", StzEngineStringCountSentences(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("the lord of the rings")
pResult = StzEngineStringTitleSmart(pStr)
Assert("TitleSmart LOTR", StzEngineStringData(pResult), "The Lord of the Rings")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("a tale of two cities")
pResult = StzEngineStringTitleSmart(pStr)
Assert("TitleSmart tale", StzEngineStringData(pResult), "A Tale of Two Cities")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello, World!")
pResult = StzEngineStringRemovePunctuation(pStr)
Assert("RemovePunctuation", StzEngineStringData(pResult), "Hello World")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("3.14")
Assert("IsFloat 3.14", StzEngineStringIsFloat(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("-0.5")
Assert("IsFloat -0.5", StzEngineStringIsFloat(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("42")
Assert("IsFloat 42 (no dot)", StzEngineStringIsFloat(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
Assert("IsFloat abc", StzEngineStringIsFloat(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("a1b2c3")
Assert("DigitSum a1b2c3", StzEngineStringDigitSum(pStr), 6)
StzEngineStringFree(pStr)

pStr = StzEngineString("999")
Assert("DigitSum 999", StzEngineStringDigitSum(pStr), 27)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
Assert("DigitSum no digits", StzEngineStringDigitSum(pStr), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 98: ToAlternatingCase / CountUpper / CountLower / IsCamelCase / CommonChars
# ==============================================================


? NL + "--- Group 98: ToAlternatingCase / CountUpper / CountLower / IsCamelCase / CommonChars ---"

pStr = StzEngineString("hello world")
pResult = StzEngineStringToAlternatingCase(pStr)
Assert("AlternatingCase hello world", StzEngineStringData(pResult), "hElLo WoRlD")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("ABC")
pResult = StzEngineStringToAlternatingCase(pStr)
Assert("AlternatingCase ABC", StzEngineStringData(pResult), "aBc")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("a")
pResult = StzEngineStringToAlternatingCase(pStr)
Assert("AlternatingCase single", StzEngineStringData(pResult), "a")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello World")
Assert("CountUpper Hello World", StzEngineStringCountUpper(pStr), 2)
StzEngineStringFree(pStr)

pStr = StzEngineString("ABC")
Assert("CountUpper ABC", StzEngineStringCountUpper(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc 123")
Assert("CountUpper none", StzEngineStringCountUpper(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello World")
Assert("CountLower Hello World", StzEngineStringCountLower(pStr), 8)
StzEngineStringFree(pStr)

pStr = StzEngineString("ABC")
Assert("CountLower ABC", StzEngineStringCountLower(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc 123")
Assert("CountLower abc 123", StzEngineStringCountLower(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("camelCase")
Assert("IsCamelCase camelCase", StzEngineStringIsCamelCase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("myVariableName")
Assert("IsCamelCase myVariableName", StzEngineStringIsCamelCase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("PascalCase")
Assert("IsCamelCase PascalCase (no)", StzEngineStringIsCamelCase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("lowercase")
Assert("IsCamelCase lowercase (no)", StzEngineStringIsCamelCase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pStr2 = StzEngineString("world")
pResult = StzEngineStringCommonChars(pStr, pStr2)
Assert("CommonChars hello/world", StzEngineStringData(pResult), "lo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
pStr2 = StzEngineString("xyz")
pResult = StzEngineStringCommonChars(pStr, pStr2)
Assert("CommonChars abc/xyz (none)", StzEngineStringData(pResult), "")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr)

pStr = StzEngineString("aabbcc")
pStr2 = StzEngineString("abcdef")
pResult = StzEngineStringCommonChars(pStr, pStr2)
Assert("CommonChars aabbcc/abcdef", StzEngineStringData(pResult), "abc")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 99: CountLines / IsSnakeCase / IsKebabCase / CountUniqueChars / Caesar
# ==============================================================


? NL + "--- Group 99: CountLines / IsSnakeCase / IsKebabCase / CountUniqueChars / Caesar ---"

pStr = StzEngineString("hello" + nl + "world" + nl + "foo")
Assert("CountLines 3", StzEngineStringCountLines(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("single line")
Assert("CountLines 1", StzEngineStringCountLines(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("")
Assert("CountLines empty", StzEngineStringCountLines(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello_world")
Assert("IsSnakeCase hello_world", StzEngineStringIsSnakeCase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("my_var_name")
Assert("IsSnakeCase my_var_name", StzEngineStringIsSnakeCase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("camelCase")
Assert("IsSnakeCase camelCase (no)", StzEngineStringIsSnakeCase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello__world")
Assert("IsSnakeCase double__ (no)", StzEngineStringIsSnakeCase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello-world")
Assert("IsKebabCase hello-world", StzEngineStringIsKebabCase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("my-var-name")
Assert("IsKebabCase my-var-name", StzEngineStringIsKebabCase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("camelCase")
Assert("IsKebabCase camelCase (no)", StzEngineStringIsKebabCase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello--world")
Assert("IsKebabCase double-- (no)", StzEngineStringIsKebabCase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
Assert("CountUniqueChars hello", StzEngineStringCountUniqueChars(pStr), 4)
StzEngineStringFree(pStr)

pStr = StzEngineString("aaa")
Assert("CountUniqueChars aaa", StzEngineStringCountUniqueChars(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("abcdef")
Assert("CountUniqueChars abcdef", StzEngineStringCountUniqueChars(pStr), 6)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
pResult = StzEngineStringCaesar(pStr, 1)
Assert("Caesar abc+1", StzEngineStringData(pResult), "bcd")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("xyz")
pResult = StzEngineStringCaesar(pStr, 3)
Assert("Caesar xyz+3 (wrap)", StzEngineStringData(pResult), "abc")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello, World!")
pResult = StzEngineStringCaesar(pStr, 13)
Assert("Caesar ROT13", StzEngineStringData(pResult), "Uryyb, Jbeyq!")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 100: Mirror / RepeatEachChar / BeginsWithAnyX / FinishesWithAnyX / ToBinary
# ==============================================================


? NL + "--- Group 100: Mirror / RepeatEachChar / BeginsWithAnyX / FinishesWithAnyX / ToBinary ---"

pStr = StzEngineString("abc")
pResult = StzEngineStringMirror(pStr)
Assert("Mirror abc", StzEngineStringData(pResult), "abccba")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("a")
pResult = StzEngineStringMirror(pStr)
Assert("Mirror single", StzEngineStringData(pResult), "aa")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
pResult = StzEngineStringRepeatEachChar(pStr, 2)
Assert("RepeatEachChar abc*2", StzEngineStringData(pResult), "aabbcc")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hi")
pResult = StzEngineStringRepeatEachChar(pStr, 3)
Assert("RepeatEachChar hi*3", StzEngineStringData(pResult), "hhhiii")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("https://example.com")
Assert("BeginsWithAnyX http|ftp", StzEngineStringBeginsWithAnyX(pStr, "http|ftp|ssh"), 1)
Assert("BeginsWithAnyX ftp|ssh (no)", StzEngineStringBeginsWithAnyX(pStr, "ftp|ssh"), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("file.zig")
Assert("FinishesWithAnyX .zig", StzEngineStringFinishesWithAnyX(pStr, ".txt|.zig|.rs"), 1)
Assert("FinishesWithAnyX .rs (no)", StzEngineStringFinishesWithAnyX(pStr, ".txt|.rs|.go"), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hi")
pResult = StzEngineStringToBinary(pStr)
Assert("ToBinary Hi", StzEngineStringData(pResult), "01001000 01101001")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 101: SortWords / UniqueWords / FromBinary / SwapWords / ToPigLatin
# ==============================================================


? NL + "--- Group 101: SortWords / UniqueWords / FromBinary / SwapWords / ToPigLatin ---"

pStr = StzEngineString("banana apple cherry")
pResult = StzEngineStingSortWords(pStr)
Assert("SortWords alphabetical", StzEngineStringData(pResult), "apple banana cherry")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("zig is fun")
pResult = StzEngineStingSortWords(pStr)
Assert("SortWords zig is fun", StzEngineStringData(pResult), "fun is zig")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("the cat and the dog and cat")
pResult = StzEngineStringUniqueWords(pStr)
Assert("UniqueWords", StzEngineStringData(pResult), "the cat and dog")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("01001000 01101001")
pResult = StzEngineStringBinary(pStr)
Assert("FromBinary -> Hi", StzEngineStringData(pResult), "Hi")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world foo")
pResult = StzEngineStringSwapWords(pStr, 0, 2)
Assert("SwapWords 0<->2", StzEngineStringData(pResult), "foo world hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pResult = StzEngineStringToPigLatin(pStr)
Assert("PigLatin hello world", StzEngineStringData(pResult), "ellohay orldway")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("apple is")
pResult = StzEngineStringToPigLatin(pStr)
Assert("PigLatin apple is", StzEngineStringData(pResult), "appleyay isyay")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 102: RunLengthEncode / RunLengthDecode / CountParagraphs / Zigzag / ToMorse
# ==============================================================


? NL + "--- Group 102: RunLengthEncode / RunLengthDecode / CountParagraphs / Zigzag / ToMorse ---"

pStr = StzEngineString("aaabbc")
pResult = StzEngineStringRunLengthEncode(pStr)
Assert("RLE encode aaabbc", StzEngineStringData(pResult), "3a2b1c")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("3a2b1c")
pResult = StzEngineStringRunLengthDecode(pStr)
Assert("RLE decode 3a2b1c", StzEngineStringData(pResult), "aaabbc")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("para1" + nl + nl + "para2" + nl + nl + "para3")
Assert("CountParagraphs 3", StzEngineStringCountParagraphs(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("single paragraph")
Assert("CountParagraphs 1", StzEngineStringCountParagraphs(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("WEAREDISCOVERED")
pResult = StzEngineStringZigzag(pStr, 3)
Assert("Zigzag 3 rails", StzEngineStringData(pResult), "WECRERDSOEEAIVD")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("SOS")
pResult = StzEngineStringToMorse(pStr)
Assert("Morse SOS", StzEngineStringData(pResult), "... --- ...")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("HI")
pResult = StzEngineStringToMorse(pStr)
Assert("Morse HI", StzEngineStringData(pResult), ".... ..")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 103: ToBase64 / FromBase64 / XorCipher / Entropy / CharFrequencyTop
# ==============================================================


? NL + "--- Group 103: ToBase64 / FromBase64 / XorCipher / Entropy / CharFrequencyTop ---"

pStr = StzEngineString("Hello")
pResult = StzEngineStringToBase64(pStr)
Assert("ToBase64 Hello", StzEngineStringData(pResult), "SGVsbG8=")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hi")
pResult = StzEngineStringToBase64(pStr)
Assert("ToBase64 Hi", StzEngineStringData(pResult), "SGk=")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("SGVsbG8=")
pResult = StzEngineStringBase64(pStr)
Assert("FromBase64 Hello", StzEngineStringData(pResult), "Hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("ABC")
pResult = StzEngineStringXorCipher(pStr, 32)
Assert("XorCipher ABC^32", StzEngineStringData(pResult), "abc")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("aaaa")
Assert("Entropy aaaa (0)", StzEngineStringEntropy(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("ab")
Assert("Entropy ab (100)", StzEngineStringEntropy(pStr), 100)
StzEngineStringFree(pStr)

pStr = StzEngineString("aabbbcc")
pResult = StzEngineStringCharFrequencyTop(pStr)
Assert("CharFreqTop aabbbcc", StzEngineStringData(pResult), "b")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 104: JaccardSimilarity / LongestCommonPrefix / LongestCommonSuffix / WrapWith / ToTitleCaseStrict
# ==============================================================


? NL + "--- Group 104: JaccardSimilarity / LongestCommonPrefix / LongestCommonSuffix / WrapWith / ToTitleCaseStrict ---"

pStr = StzEngineString("abc")
pStr2 = StzEngineString("abc")
Assert("Jaccard identical", StzEngineStringJaccardSimilarity(pStr, pStr2), 100)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
pStr2 = StzEngineString("xyz")
Assert("Jaccard disjoint", StzEngineStringJaccardSimilarity(pStr, pStr2), 0)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pStr2 = StzEngineString("hello there")
pResult = StzEngineStringLongestCommonPrefix(pStr, pStr2)
Assert("LCP hello", StzEngineStringData(pResult), "hello ")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr)

pStr = StzEngineString("testing")
pStr2 = StzEngineString("resting")
pResult = StzEngineStringLongestCommonSuffix(pStr, pStr2)
Assert("LCS esting", StzEngineStringData(pResult), "esting")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pResult = StzEngineStringWrapWith(pStr, "[", "]")
Assert("WrapWith brackets", StzEngineStringData(pResult), "[hello]")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world foo")
pResult = StzEngineStringToTitleCaseStrict(pStr)
Assert("TitleCaseStrict", StzEngineStringData(pResult), "Hello World Foo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("the LORD of war")
pResult = StzEngineStringToTitleCaseStrict(pStr)
Assert("TitleCaseStrict LORD", StzEngineStringData(pResult), "The Lord Of War")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 105: HammingWeight / IsPalindromeWords / RemoveNthWord / InsertWordAt / ToSpongebobCase
# ==============================================================


? NL + "--- Group 105: HammingWeight / IsPalindromeWords / RemoveNthWord / InsertWordAt / ToSpongebobCase ---"

pStr = StzEngineString("AB")
Assert("HammingWeight AB", StzEngineStringHammingWeight(pStr), 4)
StzEngineStringFree(pStr)

pStr = StzEngineString("dog cat dog")
Assert("IsPalindromeWords yes", StzEngineStringIsPalindromeWords(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
Assert("IsPalindromeWords no", StzEngineStringIsPalindromeWords(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world foo")
pResult = StzEngineStringRemoveNthWord(pStr, 1)
Assert("RemoveNthWord 1", StzEngineStringData(pResult), "hello foo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world foo")
pResult = StzEngineStringRemoveNthWord(pStr, 0)
Assert("RemoveNthWord 0", StzEngineStringData(pResult), "world foo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello foo")
pResult = StzEngineStringInsertWordAt(pStr, 1, "world")
Assert("InsertWordAt 1", StzEngineStringData(pResult), "hello world foo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pResult = StzEngineStringToSpongebobCase(pStr)
Assert("SpongebobCase", StzEngineStringData(pResult), "HeLlO wOrLd")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)


? NL + "--- Group 106: BetweenFirst / ToDotCase / Abbreviate / CountSubstring / ToPathCase ---"

pStr = StzEngineString("hello [world] end")
pResult = StzEngineStringBetweenFirst(pStr, "[", "]")
Assert("BetweenFirst []", StzEngineStringData(pResult), "world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("no brackets here")
pResult = StzEngineStringBetweenFirst(pStr, "[", "]")
Assert("BetweenFirst none", StzEngineStringData(pResult), "")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello World")
pResult = StzEngineStringToDotCase(pStr)
Assert("ToDotCase", StzEngineStringData(pResult), "hello.world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pResult = StzEngineStringAbbreviate(pStr, 8)
Assert("Abbreviate 8", StzEngineStringData(pResult), "hello...")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pResult = StzEngineStringAbbreviate(pStr, 50)
Assert("Abbreviate long", StzEngineStringData(pResult), "hello world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("abcabcabc")
Assert("CountSubstring abc", StzEngineStringCountSubstring(pStr, "abc"), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
Assert("CountSubstring none", StzEngineStringCountSubstring(pStr, "xyz"), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello World")
pResult = StzEngineStringToPathCase(pStr)
Assert("ToPathCase", StzEngineStringData(pResult), "hello/world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)


? NL + "--- Group 107: LeftPad / RightPad / ToHex / FromHex / Soundex ---"

pStr = StzEngineString("42")
pResult = StzEngineStingLeftPad(pStr, 5, "0")
Assert("LeftPad 0", StzEngineStringData(pResult), "00042")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hi")
pResult = StzEngineStringRightPad(pStr, 5, ".")
Assert("RightPad .", StzEngineStringData(pResult), "hi...")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("ABC")
pResult = StzEngineStringToHex(pStr)
Assert("ToHex ABC", StzEngineStringData(pResult), "414243")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("414243")
pResult = StzEngineStringHex(pStr)
Assert("FromHex 414243", StzEngineStringData(pResult), "ABC")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Robert")
pResult = StzEngineStingSoundex(pStr)
Assert("Soundex Robert", StzEngineStringData(pResult), "R163")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)


? NL + "--- Group 108: VigenereEncrypt / Atbash / CountWordsMatching / TruncateWords / ToConstantCase ---"

pStr = StzEngineString("hello")
pResult = StzEngineStringVigenereEncrypt(pStr, "key")
Assert("Vigenere hello/key", StzEngineStringData(pResult), "rijvs")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc")
pResult = StzEngineStringAtbash(pStr)
Assert("Atbash abc", StzEngineStringData(pResult), "zyx")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello")
pResult = StzEngineStringAtbash(pStr)
Assert("Atbash Hello", StzEngineStringData(pResult), "Svool")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("the cat and the dog")
Assert("CountWordsMatching the", StzEngineStringCountWordsMatching(pStr, "the"), 2)
StzEngineStringFree(pStr)

pStr = StzEngineString("one two three four five")
pResult = StzEngineStringTruncateWords(pStr, 3)
Assert("TruncateWords 3", StzEngineStringData(pResult), "one two three")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pResult = StzEngineStringToConstantCase(pStr)
Assert("ToConstantCase", StzEngineStringData(pResult), "HELLO_WORLD")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)


? NL + "--- Group 109: FirstWord / LastWord / ToNato / Commonality / DiffChars ---"

pStr = StzEngineString("hello world foo")
pResult = StzEngineStringFirstWord(pStr)
Assert("FirstWord", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world foo")
pResult = StzEngineStringLastWord(pStr)
Assert("LastWord", StzEngineStringData(pResult), "foo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("AB")
pResult = StzEngineStringToNato(pStr)
Assert("ToNato AB", StzEngineStringData(pResult), "Alfa Bravo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr1 = StzEngineString("abc")
pStr2 = StzEngineString("bcd")
Assert("Commonality abc/bcd", StzEngineStringCommonality(pStr1, pStr2), 2)
StzEngineStringFree(pStr1)
StzEngineStringFree(pStr2)

pStr1 = StzEngineString("abcd")
pStr2 = StzEngineString("bc")
pResult = StzEngineStringDiffChars(pStr1, pStr2)
Assert("DiffChars abcd-bc", StzEngineStringData(pResult), "ad")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr1)
StzEngineStringFree(pStr2)


? NL + "--- Group 110: Rot47 / IsIsogram / ReverseEachWord / CountDigits / StripTags ---"

pStr = StzEngineString("Hello")
pResult = StzEngineStringRot47(pStr)
Assert("Rot47 Hello", StzEngineStringData(pResult), "w6==@")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("abcdef")
Assert("IsIsogram yes", StzEngineStringIsIsogram(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
Assert("IsIsogram no", StzEngineStringIsIsogram(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello world")
pResult = StzEngineStringReverseEachWord(pStr)
Assert("ReverseEachWord", StzEngineStringData(pResult), "olleh dlrow")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("abc123def45")
Assert("CountDigits", StzEngineStringCountDigits(pStr), 5)
StzEngineStringFree(pStr)

pStr = StzEngineString("<b>hello</b> <i>world</i>")
pResult = StzEngineStingStripTags(pStr)
Assert("StripTags", StzEngineStringData(pResult), "hello world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)


? NL + "--- Group 111: ToSlug / CountSpaces / NormalizeSpaces / MaskEmail / Pluralize ---"

pStr = StzEngineString("Hello World! Test")
pResult = StzEngineStringToSlug(pStr)
Assert("ToSlug", StzEngineStringData(pResult), "hello-world-test")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello  world  foo")
Assert("CountSpaces", StzEngineStringCountSpaces(pStr), 4)
StzEngineStringFree(pStr)

pStr = StzEngineString("  hello   world  ")
pResult = StzEngineStringNormalizeSpaces(pStr)
Assert("NormalizeSpaces", StzEngineStringData(pResult), "hello world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("john@example.com")
pResult = StzEngineStringMaskEmail(pStr)
Assert("MaskEmail", StzEngineStringData(pResult), "j***@example.com")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("cat")
pResult = StzEngineStringPluralize(pStr)
Assert("Pluralize cat", StzEngineStringData(pResult), "cats")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("city")
pResult = StzEngineStringPluralize(pStr)
Assert("Pluralize city", StzEngineStringData(pResult), "cities")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)


? NL + "--- Group 112: DeduplicateLines / RemoveBlankLines / ExtractNumbers / ExtractEmails / Quote ---"

pStr = StzEngineString("hello" + nl + "world" + nl + "hello" + nl + "foo")
pResult = StzEngineStringDeduplicateLines(pStr)
Assert("DeduplicateLines", StzEngineStringData(pResult), "hello" + nl + "world" + nl + "foo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello" + nl + nl + "world")
pResult = StzEngineStringRemoveBlankLines(pStr)
Assert("RemoveBlankLines", StzEngineStringData(pResult), "hello" + nl + "world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("price is 42.5 and qty 10")
pResult = StzEngineStringExtractNumbers(pStr)
Assert("ExtractNumbers", StzEngineStringData(pResult), "42.5 10")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("contact john@example.com or jane@test.org")
pResult = StzEngineStringExtractEmails(pStr)
Assert("ExtractEmails", StzEngineStringData(pResult), "john@example.com jane@test.org")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pResult = StzEngineStringQuote(pStr, "'")
Assert("Quote single", StzEngineStringData(pResult), "'hello'")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)


? NL + "--- Group 113: Unquote / ToCsvField / NumberLines / Hide / ExtractWords ---"

pStr = StzEngineString('"hello"')
pResult = StzEngineStringUnquote(pStr)
Assert("Unquote", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello,world")
pResult = StzEngineStringToCsvField(pStr)
Assert("ToCsvField comma", StzEngineStringData(pResult), '"hello,world"')
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("simple")
pResult = StzEngineStringToCsvField(pStr)
Assert("ToCsvField simple", StzEngineStringData(pResult), "simple")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello" + nl + "world")
pResult = StzEngineStringNumberLines(pStr)
Assert("NumberLines", StzEngineStringData(pResult), "1: hello" + nl + "2: world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("1234567890")
pResult = StzEngineStringHide(pStr, "*", 2, 2)
Assert("Hide", StzEngineStringData(pResult), "12******90")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello, world! 123")
pResult = StzEngineStringExtractWords(pStr)
Assert("ExtractWords", StzEngineStringData(pResult), "hello world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)


? NL + "--- Group 114: ExpandTabs / SentenceCount / Chop / ScanInt / ToOrdinal ---"

pStr = StzEngineString("a" + char(9) + "b")
pResult = StzEngineStringExpandTabs(pStr, 4)
Assert("ExpandTabs", StzEngineStringData(pResult), "a    b")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello. How? Fine!")
Assert("SentenceCount", StzEngineStringSentenceCount(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineString("hello")
pResult = StzEngineStringChop(pStr)
Assert("Chop", StzEngineStringData(pResult), "hell")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("42abc")
Assert("ScanInt 42", StzEngineStingScanInt(pStr), 42)
StzEngineStringFree(pStr)

pStr = StzEngineString("1")
pResult = StzEngineStringToOrdinal(pStr)
Assert("ToOrdinal 1st", StzEngineStringData(pResult), "1st")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("23")
pResult = StzEngineStringToOrdinal(pStr)
Assert("ToOrdinal 23rd", StzEngineStringData(pResult), "23rd")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- CpCount, LeftCp, RightCp, NthChar ---

pStr = StzEngineString("Hello")
Assert("CpCount ASCII", "" + StzEngineStringCpCount(pStr), "5")
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello")
pResult = StzEngineStringLeftCp(pStr, 3)
Assert("LeftCp", StzEngineStringData(pResult), "Hel")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello")
pResult = StzEngineStringRightCp(pStr, 3)
Assert("RightCp", StzEngineStringData(pResult), "llo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("Hello")
pResult = StzEngineStringNthChar(pStr, 1)
Assert("NthChar 0", StzEngineStringData(pResult), "H")
StzEngineStringFree(pResult)
pResult = StzEngineStringNthChar(pStr, 5)
Assert("NthChar 4", StzEngineStringData(pResult), "o")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- Group 115: NLP -- Jaro, Jaro-Winkler, Metaphone, Ngrams ---

? NL + "--- Group 115: Jaro / JaroWinkler / Metaphone / CharNgrams / WordNgrams ---"

# Jaro -- identical strings = 1000
pA = StzEngineString("hello")
pB = StzEngineString("hello")
Assert("Jaro identical", StzEngineStringJaro(pA, pB), 1000)
StzEngineStringFree(pA)
StzEngineStringFree(pB)

# Jaro -- similar strings > 0
pA = StzEngineString("martha")
pB = StzEngineString("marhta")
nJaro = StzEngineStringJaro(pA, pB)
Assert("Jaro similar > 900", nJaro > 900, 1)

# Jaro-Winkler -- should be >= Jaro (prefix boost)
nJW = StzEngineStringJaroWinkler(pA, pB)
Assert("JaroWinkler >= Jaro", nJW >= nJaro, 1)
StzEngineStringFree(pA)
StzEngineStringFree(pB)

# Jaro-Winkler -- different strings = 0
pA = StzEngineString("abc")
pB = StzEngineString("xyz")
Assert("JaroWinkler different", StzEngineStringJaroWinkler(pA, pB), 0)
StzEngineStringFree(pA)
StzEngineStringFree(pB)

# Metaphone
pStr = StzEngineString("phone")
pResult = StzEngineStringMetaphone(pStr)
Assert("Metaphone phone", StzEngineStringData(pResult), "FN")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineString("smith")
pResult = StzEngineStringMetaphone(pStr)
Assert("Metaphone smith", StzEngineStringData(pResult), "SM0")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# Character n-grams (bigrams)
pStr = StzEngineString("hello")
pResult = StzEngineStringCharNgrams(pStr, 2)
Assert("CharNgrams bigrams", StzEngineStringData(pResult), "he|el|ll|lo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# Word n-grams (bigrams)
pStr = StzEngineString("the quick brown fox")
pResult = StzEngineStringWordNgrams(pStr, 2)
Assert("WordNgrams bigrams", StzEngineStringData(pResult), "the quick|quick brown|brown fox")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 116: CS Unified Functions
# ==============================================================

? NL + "--- Group 116: CS Unified Functions ---"

# IndexOfCS
pStr = StzEngineString("Hello World")
Assert("IndexOfCS cs=1 found", StzEngineStringIndexOfCS(pStr, "World", 1), 7)
Assert("IndexOfCS cs=1 not found", StzEngineStringIndexOfCS(pStr, "world", 1), -1)
Assert("IndexOfCS cs=0 found", StzEngineStringIndexOfCS(pStr, "WORLD", 0), 7)
StzEngineStringFree(pStr)

# FindAllCS
pStr = StzEngineString("abcABCabc")
pResult = StzEngineStringFindAllCS(pStr, "abc", 1)
Assert("FindAllCS cs=1 count", StzEngineFindResultCount(pResult), 2)
StzEngineFindResultFree(pResult)
pResult = StzEngineStringFindAllCS(pStr, "abc", 0)
Assert("FindAllCS cs=0 count", StzEngineFindResultCount(pResult), 3)
StzEngineFindResultFree(pResult)
StzEngineStringFree(pStr)

# ContainsCS
pStr = StzEngineString("Hello World")
Assert("ContainsCS cs=1 yes", StzEngineStringContainsCS(pStr, "World", 1), 1)
Assert("ContainsCS cs=1 no", StzEngineStringContainsCS(pStr, "world", 1), 0)
Assert("ContainsCS cs=0 yes", StzEngineStringContainsCS(pStr, "world", 0), 1)
StzEngineStringFree(pStr)

# EqualsCS
pStr1 = StzEngineString("Hello")
pStr2 = StzEngineString("hello")
Assert("EqualsCS cs=1", StzEngineStringEqualsCS(pStr1, pStr2, 1), 0)
Assert("EqualsCS cs=0", StzEngineStringEqualsCS(pStr1, pStr2, 0), 1)
StzEngineStringFree(pStr1)
StzEngineStringFree(pStr2)

# StartsWithCS / EndsWithCS
pStr = StzEngineString("Hello World")
Assert("StartsWithCS cs=0", StzEngineStringStartsWithCS(pStr, "hello", 0), 1)
Assert("EndsWithCS cs=0", StzEngineStringEndsWithCS(pStr, "WORLD", 0), 1)
StzEngineStringFree(pStr)

# CountOfCS
pStr = StzEngineString("abcABCabc")
Assert("CountOfCS cs=1", StzEngineStringCountOfCS(pStr, "abc", 1), 2)
Assert("CountOfCS cs=0", StzEngineStringCountOfCS(pStr, "abc", 0), 3)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 117: Error Reporting & Safety (Phase B)
# ==============================================================

? NL + "--- Group 117: Error Reporting & Safety ---"

# LastError initial state
StzEngineStringClearError()
Assert("LastError initial", StzEngineStringLastError(), 0)

# LastError after valid operation
pStr = StzEngineString("Hello")
Assert("LastError after valid From", StzEngineStringLastError(), 0)
StzEngineStringFree(pStr)

# ClearError works
StzEngineStringClearError()
Assert("ClearError resets", StzEngineStringLastError(), 0)

# str_data is null-terminated (verify via string comparison)
pStr = StzEngineString("Test")
Assert("Data null-terminated", StzEngineStringData(pStr), "Test")
StzEngineStringFree(pStr)

# Append on valid handle
pStr = StzEngineStringNew()
StzEngineStringAppend(pStr, "Hello")
Assert("Append valid", StzEngineStringData(pStr), "Hello")
Assert("Append no error", StzEngineStringLastError(), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  SUMMARY
# ==============================================================


? NL + "==================================="
? "Results: " + nPass + " passed, " + nFail + " failed out of " + nTotal + " tests"
if nFail = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok

# ==============================================================
#  HELPER: assert equality (must be after main code in Ring)
# ==============================================================

func Assert(cTestName, pActual, pExpected)
	nTotal++
	if pActual = pExpected
		? "  PASS: " + cTestName
		nPass++
	else
		? "  FAIL: " + cTestName + " -- expected [" + pExpected + "] got [" + pActual + "]"
		nFail++
	ok
