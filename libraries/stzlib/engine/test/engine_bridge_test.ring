? "Engine Full Bridge Test -- All 223 Registered Functions"
? "======================================================"
? ""

# Load Engine DLL directly (no stzlib dependency)
cDll = "D:\GitHub\stzlib\libraries\stzlib\engine\zig-out\bin\stz_string.dll"

if NOT fexists(cDll)
	? "ERROR: DLL not found at: " + cDll
	return
ok

pLib = LoadLib(cDll)
? "Engine DLL loaded from: " + cDll
? ""

nPass = 0
nFail = 0
nTotal = 0

# ==============================================================
#  GROUP 1: Lifecycle -- New, From, Free, Data, Size, Count
# ==============================================================

? "--- Group 1: Lifecycle ---"

pNew = StzEngineStringNew()
Assert("StringNew returns handle", type(pNew) != "NUMBER", true)
StzEngineStringFree(pNew)

pStr = StzEngineStringFrom("Hello")
Assert("StringFrom + Data", StzEngineStringData(pStr), "Hello")
Assert("StringSize (bytes)", StzEngineStringSize(pStr), 5)
Assert("StringCount (codepoints)", StzEngineStringCount(pStr), 5)
StzEngineStringFree(pStr)

# Unicode: 3-byte chars
pUni = StzEngineStringFrom("ABC")
Assert("StringCount ASCII", StzEngineStringCount(pUni), 3)
StzEngineStringFree(pUni)

# ==============================================================
#  GROUP 2: Append, Insert, Mid
# ==============================================================

? "--- Group 2: Append, Insert, Mid ---"

pStr = StzEngineStringFrom("Hello")
StzEngineStringAppend(pStr, " World")
Assert("Append", StzEngineStringData(pStr), "Hello World")

# Insert at byte position 5
pStr2 = StzEngineStringFrom("HelloWorld")
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

? "--- Group 3: Trimmed ---"

pStr = StzEngineStringFrom("  hello  ")
pTrimmed = StzEngineStringTrimmed(pStr)
Assert("Trimmed", StzEngineStringData(pTrimmed), "hello")
StzEngineStringFree(pTrimmed)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 4: IndexOf, IndexOfFrom, IndexOfCI
# ==============================================================

? "--- Group 4: IndexOf, IndexOfFrom, IndexOfCI ---"

pStr = StzEngineStringFrom("hello world hello")
nIdx = StzEngineStringIndexOf(pStr, "world")
Assert("IndexOf found", nIdx, 6)

nIdx = StzEngineStringIndexOf(pStr, "xyz")
Assert("IndexOf not found", nIdx < 0, true)

nIdx = StzEngineStringIndexOfFrom(pStr, "hello", 0)
Assert("IndexOfFrom pos 0", nIdx, 0)

nIdx = StzEngineStringIndexOfFrom(pStr, "hello", 1)
Assert("IndexOfFrom pos 1 (second)", nIdx, 12)

nIdx = StzEngineStringIndexOfCI(pStr, "HELLO", 0)
Assert("IndexOfCI", nIdx, 0)

nIdx = StzEngineStringIndexOfCI(pStr, "WORLD", 0)
Assert("IndexOfCI world", nIdx, 6)

StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 5: ByteToCp
# ==============================================================

? "--- Group 5: ByteToCp ---"

pStr = StzEngineStringFrom("hello")
nCp = StzEngineStringByteToCp(pStr, 3)
Assert("ByteToCp ASCII", nCp, 3)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 6: CountOf, CountOfCI, LastIndexOf, LastIndexOfCI
# ==============================================================

? "--- Group 6: CountOf, LastIndexOf ---"

pStr = StzEngineStringFrom("abc-abc-abc")
Assert("CountOf", StzEngineStringCountOf(pStr, "abc"), 3)
Assert("CountOf not found", StzEngineStringCountOf(pStr, "xyz"), 0)
Assert("LastIndexOf", StzEngineStringLastIndexOf(pStr, "abc"), 8)
Assert("LastIndexOf not found", StzEngineStringLastIndexOf(pStr, "xyz") < 0, true)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello hello HELLO")
Assert("CountOfCI", StzEngineStringCountOfCI(pStr, "hello"), 3)
Assert("LastIndexOfCI", StzEngineStringLastIndexOfCI(pStr, "hello"), 12)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 7: Contains, ContainsCI, StartsWith, StartsWithCI,
#           EndsWith, EndsWithCI
# ==============================================================

? "--- Group 7: Contains, StartsWith, EndsWith ---"

pStr = StzEngineStringFrom("Hello World")
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

? "--- Group 8: FindAll, FindAllCI ---"

pStr = StzEngineStringFrom("abc-abc-abc")
pResult = StzEngineStringFindAll(pStr, "abc")
nCount = StzEngineFindResultCount(pResult)
Assert("FindAll count", nCount, 3)
Assert("FindAll pos 0", StzEngineFindResultGet(pResult, 0), 0)
Assert("FindAll pos 1", StzEngineFindResultGet(pResult, 1), 4)
Assert("FindAll pos 2", StzEngineFindResultGet(pResult, 2), 8)
StzEngineFindResultFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello hello HELLO")
pResult = StzEngineStringFindAllCI(pStr, "hello")
nCount = StzEngineFindResultCount(pResult)
Assert("FindAllCI count", nCount, 3)
Assert("FindAllCI pos 0", StzEngineFindResultGet(pResult, 0), 0)
Assert("FindAllCI pos 1", StzEngineFindResultGet(pResult, 1), 6)
Assert("FindAllCI pos 2", StzEngineFindResultGet(pResult, 2), 12)
StzEngineFindResultFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 9: SplitCount, SplitGet, SplitCountCI, SplitGetCI
# ==============================================================

? "--- Group 9: Split ---"

pStr = StzEngineStringFrom("one::two::three")
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

pStr = StzEngineStringFrom("aXbXc")
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

? "--- Group 10: Replace ---"

pStr = StzEngineStringFrom("hello world hello")
StzEngineStringReplace(pStr, "hello", "HI")
Assert("Replace", StzEngineStringData(pStr), "HI world HI")
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello HELLO hello")
StzEngineStringReplaceCI(pStr, "hello", "X")
Assert("ReplaceCI", StzEngineStringData(pStr), "X X X")
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("ABCDEF")
pRR = StzEngineStringReplaceRange(pStr, 2, 2, "xx")
Assert("ReplaceRange", StzEngineStringData(pRR), "ABxxEF")
StzEngineStringFree(pRR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 11: ToUpper, ToLower, ToTitle
# ==============================================================

? "--- Group 11: Case Conversion ---"

pStr = StzEngineStringFrom("Hello World")
pUp = StzEngineStringToUpper(pStr)
Assert("ToUpper", StzEngineStringData(pUp), "HELLO WORLD")
StzEngineStringFree(pUp)

pLo = StzEngineStringToLower(pStr)
Assert("ToLower", StzEngineStringData(pLo), "hello world")
StzEngineStringFree(pLo)

pStr2 = StzEngineStringFrom("hello world")
pTi = StzEngineStringToTitle(pStr2)
cTitle = StzEngineStringData(pTi)
Assert("ToTitle first H", substr(cTitle, 1, 1), "H")
StzEngineStringFree(pTi)
StzEngineStringFree(pStr)
StzEngineStringFree(pStr2)

# ==============================================================
#  GROUP 12: CharAt, MidCp, NthChar, Slice
# ==============================================================

? "--- Group 12: CharAt, MidCp, NthChar, Slice ---"

pStr = StzEngineStringFrom("Hello")
nCh = StzEngineStringCharAt(pStr, 0)
Assert("CharAt 0 = H (72)", nCh, 72)

nCh = StzEngineStringCharAt(pStr, 4)
Assert("CharAt 4 = o (111)", nCh, 111)

pMid = StzEngineStringMidCp(pStr, 1, 3)
Assert("MidCp(1,3)", StzEngineStringData(pMid), "ell")
StzEngineStringFree(pMid)

pNth = StzEngineStringNthChar(pStr, 0)
Assert("NthChar 0", StzEngineStringData(pNth), "H")
StzEngineStringFree(pNth)
pNth = StzEngineStringNthChar(pStr, 4)
Assert("NthChar 4", StzEngineStringData(pNth), "o")
StzEngineStringFree(pNth)

pSlice = StzEngineStringSlice(pStr, 1, 3)
Assert("Slice(1,3)", StzEngineStringData(pSlice), "ell")
StzEngineStringFree(pSlice)

StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 13: GraphemeCount, Normalize, StripMarks
# ==============================================================

? "--- Group 13: GraphemeCount, Normalize, StripMarks ---"

pStr = StzEngineStringFrom("Hello")
nGr = StzEngineStringGraphemeCount(pStr)
Assert("GraphemeCount ASCII", nGr, 5)
StzEngineStringFree(pStr)

# Normalize NFC (form=0)
pStr = StzEngineStringFrom("test")
pNorm = StzEngineStringNormalize(pStr, 0)
Assert("Normalize NFC", StzEngineStringData(pNorm), "test")
StzEngineStringFree(pNorm)
StzEngineStringFree(pStr)

# StripMarks on ASCII (no change)
pStr = StzEngineStringFrom("Hello")
pStripped = StzEngineStringStripMarks(pStr)
Assert("StripMarks ASCII", StzEngineStringData(pStripped), "Hello")
StzEngineStringFree(pStripped)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 14: Char module -- CharUnicode, CharIsLetter/Digit/Upper/Lower
# ==============================================================

? "--- Group 14: Char module ---"

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

? "--- Group 15: Reverse, Repeat, Pad ---"

pStr = StzEngineStringFrom("Hello")
pRev = StzEngineStringReverse(pStr)
Assert("Reverse", StzEngineStringData(pRev), "olleH")
StzEngineStringFree(pRev)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("ab")
pRep = StzEngineStringRepeat(pStr, 3)
Assert("Repeat 3", StzEngineStringData(pRep), "ababab")
StzEngineStringFree(pRep)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hi")
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

? "--- Group 16: RemoveRange, TrimLeft, TrimRight ---"

pStr = StzEngineStringFrom("ABCDEF")
pRR = StzEngineStringRemoveRange(pStr, 2, 2)
Assert("RemoveRange", StzEngineStringData(pRR), "ABEF")
StzEngineStringFree(pRR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("   hello")
pTL = StzEngineStringTrimLeft(pStr)
Assert("TrimLeft", StzEngineStringData(pTL), "hello")
StzEngineStringFree(pTL)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello   ")
pTR = StzEngineStringTrimRight(pStr)
Assert("TrimRight", StzEngineStringData(pTR), "hello")
StzEngineStringFree(pTR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 17: Equals, EqualsCI
# ==============================================================

? "--- Group 17: Equals ---"

pStr1 = StzEngineStringFrom("Hello")
pStr2 = StzEngineStringFrom("Hello")
pStr3 = StzEngineStringFrom("hello")
Assert("Equals same", StzEngineStringEquals(pStr1, pStr2), 1)
Assert("Equals diff case", StzEngineStringEquals(pStr1, pStr3), 0)
Assert("EqualsCI", StzEngineStringEqualsCI(pStr1, pStr3), 1)
StzEngineStringFree(pStr1)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr3)

# ==============================================================
#  GROUP 18: ReplaceFirst, ReplaceLast, ReplaceNth
# ==============================================================

? "--- Group 18: ReplaceFirst/Last/Nth ---"

pStr = StzEngineStringFrom("abc-abc-abc")
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

? "--- Group 19: IsEmpty, Between ---"

pEmpty = StzEngineStringFrom("")
Assert("IsEmpty yes", StzEngineStringIsEmpty(pEmpty), 1)
StzEngineStringFree(pEmpty)

pStr = StzEngineStringFrom("hello")
Assert("IsEmpty no", StzEngineStringIsEmpty(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("[hello world]")
pBet = StzEngineStringBetween(pStr, "[", "]")
Assert("Between []", StzEngineStringData(pBet), "hello world")
StzEngineStringFree(pBet)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("<<value>>")
pBet = StzEngineStringBetween(pStr, "<<", ">>")
Assert("Between << >>", StzEngineStringData(pBet), "value")
StzEngineStringFree(pBet)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 20: CountCharsOfType, IsNumeric, IsAlpha
# ==============================================================

? "--- Group 20: CountCharsOfType, IsNumeric, IsAlpha ---"

pStr = StzEngineStringFrom("Hello 123!")
Assert("CountCharsOfType letters", StzEngineStringCountCharsOfType(pStr, 0), 5)
Assert("CountCharsOfType digits", StzEngineStringCountCharsOfType(pStr, 1), 3)
Assert("CountCharsOfType spaces", StzEngineStringCountCharsOfType(pStr, 2), 1)
Assert("CountCharsOfType upper", StzEngineStringCountCharsOfType(pStr, 3), 1)
Assert("CountCharsOfType lower", StzEngineStringCountCharsOfType(pStr, 4), 4)
Assert("CountCharsOfType punct", StzEngineStringCountCharsOfType(pStr, 5), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("12345")
Assert("IsNumeric yes", StzEngineStringIsNumeric(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("12a45")
Assert("IsNumeric no", StzEngineStringIsNumeric(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello")
Assert("IsAlpha yes", StzEngineStringIsAlpha(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello1")
Assert("IsAlpha no", StzEngineStringIsAlpha(pStr), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 21: FindNth, FindNthCI
# ==============================================================

? "--- Group 21: FindNth ---"

pStr = StzEngineStringFrom("abc-abc-abc")
Assert("FindNth 1", StzEngineStringFindNth(pStr, "abc", 1), 0)
Assert("FindNth 2", StzEngineStringFindNth(pStr, "abc", 2), 4)
Assert("FindNth 3", StzEngineStringFindNth(pStr, "abc", 3), 8)
Assert("FindNth 4 (not found)", StzEngineStringFindNth(pStr, "abc", 4) < 0, true)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello hello HELLO")
Assert("FindNthCI 1", StzEngineStringFindNthCI(pStr, "hello", 1), 0)
Assert("FindNthCI 2", StzEngineStringFindNthCI(pStr, "hello", 2), 6)
Assert("FindNthCI 3", StzEngineStringFindNthCI(pStr, "hello", 3), 12)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 22: InsertCp, LeftCp, RightCp
# ==============================================================

? "--- Group 22: InsertCp, LeftCp, RightCp ---"

pStr = StzEngineStringFrom("HelloWorld")
StzEngineStringInsertCp(pStr, 5, " ")
Assert("InsertCp", StzEngineStringData(pStr), "Hello World")
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello World")
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

? "--- Group 23: RemoveAll, LinesCount, IsPalindrome, Concat ---"

pStr = StzEngineStringFrom("abc--def--ghi")
pRemoved = StzEngineStringRemoveAll(pStr, "--")
Assert("RemoveAll", StzEngineStringData(pRemoved), "abcdefghi")
StzEngineStringFree(pRemoved)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("line1" + char(10) + "line2" + char(10) + "line3")
Assert("LinesCount 3", StzEngineStringLinesCount(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
Assert("LinesCount 1", StzEngineStringLinesCount(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("")
Assert("LinesCount empty", StzEngineStringLinesCount(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("racecar")
Assert("IsPalindrome yes", StzEngineStringIsPalindrome(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
Assert("IsPalindrome no", StzEngineStringIsPalindrome(pStr), 0)
StzEngineStringFree(pStr)

pStr1 = StzEngineStringFrom("Hello ")
pStr2 = StzEngineStringFrom("World")
pConcat = StzEngineStringConcat(pStr1, pStr2)
Assert("Concat", StzEngineStringData(pConcat), "Hello World")
StzEngineStringFree(pConcat)
StzEngineStringFree(pStr1)
StzEngineStringFree(pStr2)

# ==============================================================
#  GROUP 24: IsAscii, RemoveCharAt, CharTypeAt
# ==============================================================

? "--- Group 24: IsAscii, RemoveCharAt, CharTypeAt ---"

pStr = StzEngineStringFrom("Hello")
Assert("IsAscii yes", StzEngineStringIsAscii(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("ABCDE")
pRemoved = StzEngineStringRemoveCharAt(pStr, 2)
Assert("RemoveCharAt 2", StzEngineStringData(pRemoved), "ABDE")
StzEngineStringFree(pRemoved)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("A1 !")
Assert("CharTypeAt 0 upper", StzEngineStringCharTypeAt(pStr, 0), 3)
Assert("CharTypeAt 1 digit", StzEngineStringCharTypeAt(pStr, 1), 1)
Assert("CharTypeAt 2 space", StzEngineStringCharTypeAt(pStr, 2), 2)
Assert("CharTypeAt 3 punct", StzEngineStringCharTypeAt(pStr, 3), 5)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 25: FindCharsOfType, ExtractCharsOfType
# ==============================================================

? "--- Group 25: FindCharsOfType, ExtractCharsOfType ---"

pStr = StzEngineStringFrom("a1b2c3")
pResult = StzEngineStringFindCharsOfType(pStr, 1)  # digits
nCount = StzEngineFindResultCount(pResult)
Assert("FindCharsOfType digit count", nCount, 3)
Assert("FindCharsOfType digit pos0", StzEngineFindResultGet(pResult, 0), 1)
Assert("FindCharsOfType digit pos1", StzEngineFindResultGet(pResult, 1), 3)
Assert("FindCharsOfType digit pos2", StzEngineFindResultGet(pResult, 2), 5)
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

? "--- Group 26: IsUppercase, IsLowercase, IsWhitespace, WordCount, IsOnlyType ---"

pStr = StzEngineStringFrom("HELLO")
Assert("IsUppercase yes", StzEngineStringIsUppercase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello")
Assert("IsUppercase no", StzEngineStringIsUppercase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("HELLO 123!")
Assert("IsUppercase with non-letters", StzEngineStringIsUppercase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
Assert("IsLowercase yes", StzEngineStringIsLowercase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello")
Assert("IsLowercase no", StzEngineStringIsLowercase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("   ")
Assert("IsWhitespace yes", StzEngineStringIsWhitespace(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom(" a ")
Assert("IsWhitespace no", StzEngineStringIsWhitespace(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("")
Assert("IsWhitespace empty", StzEngineStringIsWhitespace(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello world")
Assert("WordCount 2", StzEngineStringWordCount(pStr), 2)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("  hello   world  ")
Assert("WordCount 2 padded", StzEngineStringWordCount(pStr), 2)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("one")
Assert("WordCount 1", StzEngineStringWordCount(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("")
Assert("WordCount 0", StzEngineStringWordCount(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abc")
Assert("IsOnlyType letters", StzEngineStringIsOnlyType(pStr, 0), 1)
Assert("IsOnlyType digits", StzEngineStringIsOnlyType(pStr, 1), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("123")
Assert("IsOnlyType digits", StzEngineStringIsOnlyType(pStr, 1), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("   ")
Assert("IsOnlyType spaces", StzEngineStringIsOnlyType(pStr, 2), 1)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 27: RemoveCharsOfType, Trim, SwapCase
# ==============================================================

? "--- Group 27: RemoveCharsOfType, Trim, SwapCase ---"

pStr = StzEngineStringFrom("Hello 123!")
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

pStr = StzEngineStringFrom("  hello  ")
pTrimmed = StzEngineStringTrim(pStr)
Assert("Trim", StzEngineStringData(pTrimmed), "hello")
StzEngineStringFree(pTrimmed)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
pTrimmed = StzEngineStringTrim(pStr)
Assert("Trim no-op", StzEngineStringData(pTrimmed), "hello")
StzEngineStringFree(pTrimmed)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello World")
pSwapped = StzEngineStringSwapCase(pStr)
Assert("SwapCase", StzEngineStringData(pSwapped), "hELLO wORLD")
StzEngineStringFree(pSwapped)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("123")
pSwapped = StzEngineStringSwapCase(pStr)
Assert("SwapCase digits", StzEngineStringData(pSwapped), "123")
StzEngineStringFree(pSwapped)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 28: UniqueChars, UniqueCharsCount
# ==============================================================

? "--- Group 28: UniqueChars, UniqueCharsCount ---"

pStr = StzEngineStringFrom("aabbcc")
pUniq = StzEngineStringUniqueChars(pStr)
Assert("UniqueChars aabbcc", StzEngineStringData(pUniq), "abc")
StzEngineStringFree(pUniq)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello")
pUniq = StzEngineStringUniqueChars(pStr)
Assert("UniqueChars Hello", StzEngineStringData(pUniq), "Helo")
StzEngineStringFree(pUniq)

Assert("UniqueCharsCount Hello", StzEngineStringUniqueCharsCount(pStr), 4)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abcabc")
Assert("UniqueCharsCount abcabc", StzEngineStringUniqueCharsCount(pStr), 3)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 29: RemoveAllCI
# ==============================================================

? "--- Group 29: RemoveAllCI ---"

pStr = StzEngineStringFrom("Hello HELLO hello world")
pResult = StzEngineStringRemoveAllCI(pStr, "hello")
Assert("RemoveAllCI", StzEngineStringData(pResult), "   world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 30: IsAlphaOnly, IsAlnum
# ==============================================================

? "--- Group 30: IsAlphaOnly, IsAlnum ---"

pStr = StzEngineStringFrom("Hello")
Assert("IsAlphaOnly yes", StzEngineStringIsAlphaOnly(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello123")
Assert("IsAlphaOnly no", StzEngineStringIsAlphaOnly(pStr), 0)
Assert("IsAlnum yes", StzEngineStringIsAlnum(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello 123")
Assert("IsAlnum no (space)", StzEngineStringIsAlnum(pStr), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 31: ContainsChar
# ==============================================================

? "--- Group 31: ContainsChar ---"

pStr = StzEngineStringFrom("Hello")
Assert("ContainsChar H", StzEngineStringContainsChar(pStr, 72), 1)
Assert("ContainsChar o", StzEngineStringContainsChar(pStr, 111), 1)
Assert("ContainsChar Z", StzEngineStringContainsChar(pStr, 90), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 32: BetweenNth, CountBetween
# ==============================================================

? "--- Group 32: BetweenNth, CountBetween ---"

pStr = StzEngineStringFrom("[a] [b] [c]")
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

pStr = StzEngineStringFrom("no brackets")
Assert("CountBetween none", StzEngineStringCountBetween(pStr, "[", "]"), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 33: ReplaceCharAt
# ==============================================================

? "--- Group 33: ReplaceCharAt ---"

pStr = StzEngineStringFrom("Hello")
pR = StzEngineStringReplaceCharAt(pStr, 0, "J")
Assert("ReplaceCharAt 0->J", StzEngineStringData(pR), "Jello")
StzEngineStringFree(pR)

pR2 = StzEngineStringReplaceCharAt(pStr, 4, "!")
Assert("ReplaceCharAt 4->!", StzEngineStringData(pR2), "Hell!")
StzEngineStringFree(pR2)

StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 34: LevenshteinDistance
# ==============================================================

? "--- Group 34: LevenshteinDistance ---"

pS1 = StzEngineStringFrom("kitten")
pS2 = StzEngineStringFrom("sitting")
Assert("Levenshtein kitten/sitting", StzEngineStringLevenshteinDistance(pS1, pS2), 3)
StzEngineStringFree(pS1)
StzEngineStringFree(pS2)

pS1 = StzEngineStringFrom("hello")
pS2 = StzEngineStringFrom("hello")
Assert("Levenshtein same", StzEngineStringLevenshteinDistance(pS1, pS2), 0)
StzEngineStringFree(pS1)
StzEngineStringFree(pS2)

pS1 = StzEngineStringFrom("")
pS2 = StzEngineStringFrom("abc")
Assert("Levenshtein empty/abc", StzEngineStringLevenshteinDistance(pS1, pS2), 3)
StzEngineStringFree(pS1)
StzEngineStringFree(pS2)

# ==============================================================
#  GROUP 35: IsTitleCase
# ==============================================================

? "--- Group 35: IsTitleCase ---"

pStr = StzEngineStringFrom("Hello World")
Assert("IsTitleCase yes", StzEngineStringIsTitleCase(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello world")
Assert("IsTitleCase no", StzEngineStringIsTitleCase(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("HELLO")
Assert("IsTitleCase HELLO no", StzEngineStringIsTitleCase(pStr), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 36: LinesSplitCount, LineAt
# ==============================================================

? "--- Group 36: LinesSplitCount, LineAt ---"

pStr = StzEngineStringFrom("line1" + char(10) + "line2" + char(10) + "line3")
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

pStr = StzEngineStringFrom("single line")
Assert("LinesSplitCount 1", StzEngineStringLinesSplitCount(pStr), 1)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 37: Simplify
# ==============================================================

? "--- Group 37: Simplify ---"

pStr = StzEngineStringFrom("  hello   world  ")
pR = StzEngineStringSimplify(pStr)
Assert("Simplify spaces", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom(char(9) + "hello" + char(10) + char(10) + "  world" + char(13) + char(10))
pR = StzEngineStringSimplify(pStr)
Assert("Simplify tabs/nl", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 38: StartsWithLetter/Digit, EndsWithLetter/Digit
# ==============================================================

? "--- Group 38: StartsWithLetter/Digit, EndsWithLetter/Digit ---"

pStr = StzEngineStringFrom("Hello123")
Assert("StartsWithLetter yes", StzEngineStringStartsWithLetter(pStr), 1)
Assert("StartsWithDigit no", StzEngineStringStartsWithDigit(pStr), 0)
Assert("EndsWithDigit yes", StzEngineStringEndsWithDigit(pStr), 1)
Assert("EndsWithLetter no", StzEngineStringEndsWithLetter(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("123Hello")
Assert("StartsWithDigit yes", StzEngineStringStartsWithDigit(pStr), 1)
Assert("StartsWithLetter no", StzEngineStringStartsWithLetter(pStr), 0)
Assert("EndsWithLetter yes", StzEngineStringEndsWithLetter(pStr), 1)
Assert("EndsWithDigit no", StzEngineStringEndsWithDigit(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 39: IsWord ---
? "--- Group 39: IsWord ---"
pStr = StzEngineStringFrom("hello-world_123", 15)
Assert("IsWord yes", StzEngineStringIsWord(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello world", 11)
Assert("IsWord no (space)", StzEngineStringIsWord(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello!", 6)
Assert("IsWord no (punct)", StzEngineStringIsWord(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("", 0)
Assert("IsWord empty", StzEngineStringIsWord(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 40: CountLeadingChar, CountTrailingChar ---
? "--- Group 40: CountLeadingChar, CountTrailingChar ---"
pStr = StzEngineStringFrom("   hello", 8)
Assert("CountLeadingChar 3 spaces", StzEngineStringCountLeadingChar(pStr, 32), 3)
Assert("CountTrailingChar 0 spaces", StzEngineStringCountTrailingChar(pStr, 32), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello...", 8)
Assert("CountLeadingChar 0 dots", StzEngineStringCountLeadingChar(pStr, 46), 0)
Assert("CountTrailingChar 3 dots", StzEngineStringCountTrailingChar(pStr, 46), 3)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("aaabbb", 6)
Assert("CountLeadingChar 3 a's", StzEngineStringCountLeadingChar(pStr, 97), 3)
Assert("CountTrailingChar 3 b's", StzEngineStringCountTrailingChar(pStr, 98), 3)
StzEngineStringFree(pStr)

# --- Group 41: IsNumericString ---
? "--- Group 41: IsNumericString ---"
pStr = StzEngineStringFrom("12345", 5)
Assert("IsNumericString digits", StzEngineStringIsNumericString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("+42", 3)
Assert("IsNumericString +42", StzEngineStringIsNumericString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("-7", 2)
Assert("IsNumericString -7", StzEngineStringIsNumericString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("12.5", 4)
Assert("IsNumericString no (dot)", StzEngineStringIsNumericString(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abc", 3)
Assert("IsNumericString no (letters)", StzEngineStringIsNumericString(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 42: URLEncode, URLDecode ---
? "--- Group 42: URLEncode, URLDecode ---"
pStr = StzEngineStringFrom("hello world", 11)
pEnc = StzEngineStringURLEncode(pStr)
Assert("URLEncode spaces", StzEngineStringData(pEnc), "hello%20world")
pDec = StzEngineStringURLDecode(pEnc)
Assert("URLDecode roundtrip", StzEngineStringData(pDec), "hello world")
StzEngineStringFree(pDec)
StzEngineStringFree(pEnc)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("a+b=c&d", 7)
pEnc = StzEngineStringURLEncode(pStr)
Assert("URLEncode special", StzEngineStringData(pEnc), "a%2Bb%3Dc%26d")
StzEngineStringFree(pEnc)
StzEngineStringFree(pStr)

# --- Group 43: CharAtToString ---
? "--- Group 43: CharAtToString ---"
pStr = StzEngineStringFrom("Hello", 5)
pCh = StzEngineStringCharAtToString(pStr, 0)
Assert("CharAtToString 0=H", StzEngineStringData(pCh), "H")
StzEngineStringFree(pCh)
pCh = StzEngineStringCharAtToString(pStr, 4)
Assert("CharAtToString 4=o", StzEngineStringData(pCh), "o")
StzEngineStringFree(pCh)
StzEngineStringFree(pStr)

# --- Group 44: Spacify ---
? "--- Group 44: Spacify ---"
pStr = StzEngineStringFrom("abc", 3)
pR = StzEngineStringSpacify(pStr)
Assert("Spacify abc", StzEngineStringData(pR), "a b c")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("X", 1)
pR = StzEngineStringSpacify(pStr)
Assert("Spacify single", StzEngineStringData(pR), "X")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 45: BytesPerChar ---
? "--- Group 45: BytesPerChar ---"
pStr = StzEngineStringFrom("ab", 2)
pR = StzEngineStringBytesPerChar(pStr)
Assert("BytesPerChar ASCII", StzEngineStringData(pR), "1 1")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 46: IsHexString, IsBinaryString, IsOctalString ---
? "--- Group 46: IsHexString, IsBinaryString, IsOctalString ---"
pStr = StzEngineStringFrom("0xFF", 4)
Assert("IsHexString 0xFF", StzEngineStringIsHexString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("deadBEEF", 8)
Assert("IsHexString deadBEEF", StzEngineStringIsHexString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("GHIJ", 4)
Assert("IsHexString no", StzEngineStringIsHexString(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("0b1010", 6)
Assert("IsBinaryString 0b1010", StzEngineStringIsBinaryString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("1100", 4)
Assert("IsBinaryString 1100", StzEngineStringIsBinaryString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("1020", 4)
Assert("IsBinaryString no", StzEngineStringIsBinaryString(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("0o777", 5)
Assert("IsOctalString 0o777", StzEngineStringIsOctalString(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("0o89", 4)
Assert("IsOctalString no", StzEngineStringIsOctalString(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 47: WordAt ---
? "--- Group 47: WordAt ---"
pStr = StzEngineStringFrom("hello world foo", 15)
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
? "--- Group 48: Center ---"
pStr = StzEngineStringFrom("hi", 2)
pR = StzEngineStringCenter(pStr, 6, 32)
Assert("Center hi in 6", StzEngineStringData(pR), "  hi  ")
StzEngineStringFree(pR)
pR = StzEngineStringCenter(pStr, 7, 32)
Assert("Center hi in 7", StzEngineStringData(pR), "  hi   ")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 49: RemoveConsecutiveDuplicates ---
? "--- Group 49: RemoveConsecutiveDuplicates ---"
pStr = StzEngineStringFrom("aabbcc", 6)
pR = StzEngineStringRemoveConsecutiveDuplicates(pStr)
Assert("RemoveConsecDups aabbcc", StzEngineStringData(pR), "abc")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("mississippi", 11)
pR = StzEngineStringRemoveConsecutiveDuplicates(pStr)
Assert("RemoveConsecDups mississippi", StzEngineStringData(pR), "misisipi")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello", 5)
pR = StzEngineStringRemoveConsecutiveDuplicates(pStr)
Assert("RemoveConsecDups hello", StzEngineStringData(pR), "helo")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 50: Substring ---
? "--- Group 50: Substring ---"
pStr = StzEngineStringFrom("Hello World", 11)
pSub = StzEngineStringSubstring(pStr, 0, 4)
Assert("Substring 0-4", StzEngineStringData(pSub), "Hello")
StzEngineStringFree(pSub)
pSub = StzEngineStringSubstring(pStr, 6, 10)
Assert("Substring 6-10", StzEngineStringData(pSub), "World")
StzEngineStringFree(pSub)
StzEngineStringFree(pStr)

# --- Group 51: ReplaceSubstring ---
? "--- Group 51: ReplaceSubstring ---"
pStr = StzEngineStringFrom("Hello World", 11)
pR = StzEngineStringReplaceSubstring(pStr, 6, 10, "Zig", 3)
Assert("ReplaceSubstring", StzEngineStringData(pR), "Hello Zig")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 52: PrefixCount, SuffixCount ---
? "--- Group 52: PrefixCount, SuffixCount ---"
pStr = StzEngineStringFrom("ababab", 6)
Assert("PrefixCount ab", StzEngineStringPrefixCount(pStr, "ab"), 3)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("xyzxyzxyz", 9)
Assert("SuffixCount xyz", StzEngineStringSuffixCount(pStr, "xyz"), 3)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello", 5)
Assert("PrefixCount h", StzEngineStringPrefixCount(pStr, "h"), 1)
Assert("SuffixCount o", StzEngineStringSuffixCount(pStr, "o"), 1)
StzEngineStringFree(pStr)

# --- Group 53: CommonPrefix, CommonSuffix ---
? "--- Group 53: CommonPrefix, CommonSuffix ---"
pStr1 = StzEngineStringFrom("hello world", 11)
pStr2 = StzEngineStringFrom("hello there", 11)
pCP = StzEngineStringCommonPrefix(pStr1, pStr2)
Assert("CommonPrefix", StzEngineStringData(pCP), "hello ")
StzEngineStringFree(pCP)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr1 = StzEngineStringFrom("testing", 7)
pStr2 = StzEngineStringFrom("working", 7)
pCS = StzEngineStringCommonSuffix(pStr1, pStr2)
Assert("CommonSuffix", StzEngineStringData(pCS), "ing")
StzEngineStringFree(pCS)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

# --- Group 54: SortCharsAsc, SortCharsDesc ---
? "--- Group 54: SortCharsAsc, SortCharsDesc ---"
pStr = StzEngineStringFrom("dcba")
pR = StzEngineStringSortCharsAsc(pStr)
Assert("SortCharsAsc dcba", StzEngineStringData(pR), "abcd")
StzEngineStringFree(pR)
pR = StzEngineStringSortCharsDesc(pStr)
Assert("SortCharsDesc dcba", StzEngineStringData(pR), "dcba")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 55: FindAllChar, Hash, CountChar, ReplaceChar ---
? "--- Group 55: FindAllChar, Hash, CountChar, ReplaceChar ---"
pStr = StzEngineStringFrom("abcabc")
pFR = StzEngineStringFindAllChar(pStr, 97)
Assert("FindAllChar a count", StzEngineFindResultCount(pFR), 2)
Assert("FindAllChar a pos0", StzEngineFindResultGet(pFR, 0), 0)
Assert("FindAllChar a pos1", StzEngineFindResultGet(pFR, 1), 3)
StzEngineFindResultFree(pFR)
StzEngineStringFree(pStr)

pStr1 = StzEngineStringFrom("hello")
pStr2 = StzEngineStringFrom("hello")
Assert("Hash same", StzEngineStringHash(pStr1), StzEngineStringHash(pStr2))
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr = StzEngineStringFrom("mississippi")
Assert("CountChar s", StzEngineStringCountChar(pStr, 115), 4)
Assert("CountChar i", StzEngineStringCountChar(pStr, 105), 4)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
pR = StzEngineStringReplaceChar(pStr, 108, 114)
Assert("ReplaceChar l->r", StzEngineStringData(pR), "herro")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 56: Copy ---
? "--- Group 56: Copy ---"
pStr = StzEngineStringFrom("Hello World")
pCopy = StzEngineStringCopy(pStr)
Assert("Copy data", StzEngineStringData(pCopy), "Hello World")
Assert("Copy size", StzEngineStringSize(pCopy), 11)
StzEngineStringFree(pCopy)
StzEngineStringFree(pStr)

# --- Group 57: Compare ---
? "--- Group 57: Compare ---"
pA = StzEngineStringFrom("abc")
pB = StzEngineStringFrom("abc")
pC = StzEngineStringFrom("abd")
pD = StzEngineStringFrom("ab")
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
? "--- Group 58: RemoveFirst/Last/NthOccurrence ---"
pStr = StzEngineStringFrom("hello world hello")
pR = StzEngineStringRemoveFirstOccurrence(pStr, "hello")
Assert("RemoveFirst hello", StzEngineStringData(pR), " world hello")
StzEngineStringFree(pR)
pR = StzEngineStringRemoveLastOccurrence(pStr, "hello")
Assert("RemoveLast hello", StzEngineStringData(pR), "hello world ")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abcabcabc")
pR = StzEngineStringRemoveNthOccurrence(pStr, "abc", 0)
Assert("RemoveNth 0", StzEngineStringData(pR), "abcabc")
StzEngineStringFree(pR)
pR = StzEngineStringRemoveNthOccurrence(pStr, "abc", 2)
Assert("RemoveNth 2", StzEngineStringData(pR), "abcabc")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 59: IsCharsSortedAsc/Desc ---
? "--- Group 59: IsCharsSortedAsc/Desc ---"
pStr = StzEngineStringFrom("abcd")
Assert("SortedAsc abcd", StzEngineStringIsCharsSortedAsc(pStr), 1)
Assert("SortedDesc abcd", StzEngineStringIsCharsSortedDesc(pStr), 0)
StzEngineStringFree(pStr)
pStr = StzEngineStringFrom("dcba")
Assert("SortedAsc dcba", StzEngineStringIsCharsSortedAsc(pStr), 0)
Assert("SortedDesc dcba", StzEngineStringIsCharsSortedDesc(pStr), 1)
StzEngineStringFree(pStr)

# --- Group 60: RepeatChar ---
? "--- Group 60: RepeatChar ---"
pR = StzEngineStringRepeatChar(42, 5)
Assert("RepeatChar * x5", StzEngineStringData(pR), "*****")
StzEngineStringFree(pR)

# --- Group 61: InsertBeforeEach, InsertAfterEach ---
? "--- Group 61: InsertBeforeEach, InsertAfterEach ---"
pStr = StzEngineStringFrom("abcabc")
pR = StzEngineStringInsertBeforeEach(pStr, "abc", "[")
Assert("InsertBeforeEach", StzEngineStringData(pR), "[abc[abc")
StzEngineStringFree(pR)
pR = StzEngineStringInsertAfterEach(pStr, "abc", "]")
Assert("InsertAfterEach", StzEngineStringData(pR), "abc]abc]")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 62: Truncate ---
? "--- Group 62: Truncate ---"
pStr = StzEngineStringFrom("Hello World")
pR = StzEngineStringTruncate(pStr, 5, "...")
Assert("Truncate 5", StzEngineStringData(pR), "Hello...")
StzEngineStringFree(pR)
pR = StzEngineStringTruncate(pStr, 20, "...")
Assert("Truncate no-op", StzEngineStringData(pR), "Hello World")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 63: WrapAt ---
? "--- Group 63: WrapAt ---"
pStr = StzEngineStringFrom("hello world foo bar")
pR = StzEngineStringWrapAt(pStr, 10)
Assert("WrapAt 10", StzEngineStringData(pR), "hello" + nl + "world foo" + nl + "bar")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 64: RemovePrefix, RemoveSuffix ---
? "--- Group 64: RemovePrefix, RemoveSuffix ---"
pStr = StzEngineStringFrom("Hello World")
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
? "--- Group 65: EnsurePrefix, EnsureSuffix ---"
pStr = StzEngineStringFrom("world")
pR = StzEngineStringEnsurePrefix(pStr, "hello ")
Assert("EnsurePrefix add", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello world")
pR = StzEngineStringEnsurePrefix(pStr, "hello")
Assert("EnsurePrefix noop", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
pR = StzEngineStringEnsureSuffix(pStr, ".txt")
Assert("EnsureSuffix add", StzEngineStringData(pR), "hello world.txt")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 66: SqueezeChar ---
? "--- Group 66: SqueezeChar ---"
pStr = StzEngineStringFrom("heeellooo")
pR = StzEngineStringSqueezeChar(pStr, 101)
Assert("SqueezeChar e", StzEngineStringData(pR), "hellooo")
StzEngineStringFree(pR)
pR = StzEngineStringSqueezeChar(pStr, 111)
Assert("SqueezeChar o", StzEngineStringData(pR), "heeello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 67: CapitalizeFirst, DecapitalizeFirst ---
? "--- Group 67: CapitalizeFirst, DecapitalizeFirst ---"
pStr = StzEngineStringFrom("hello world")
pR = StzEngineStringCapitalizeFirst(pStr)
Assert("CapitalizeFirst", StzEngineStringData(pR), "Hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello")
pR = StzEngineStringDecapitalizeFirst(pStr)
Assert("DecapitalizeFirst", StzEngineStringData(pR), "hello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 68: ZFill ---
? "--- Group 68: ZFill ---"
pStr = StzEngineStringFrom("42")
pR = StzEngineStringZFill(pStr, 5)
Assert("ZFill 42->00042", StzEngineStringData(pR), "00042")
StzEngineStringFree(pR)
pR = StzEngineStringZFill(pStr, 2)
Assert("ZFill no-op", StzEngineStringData(pR), "42")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 69: TabExpand ---
? "--- Group 69: TabExpand ---"
pStr = StzEngineStringFrom("a" + char(9) + "b")
pR = StzEngineStringTabExpand(pStr, 4)
Assert("TabExpand 4", StzEngineStringData(pR), "a    b")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 70: CountOverlapping ---
? "--- Group 70: CountOverlapping ---"
pStr = StzEngineStringFrom("aaaa")
Assert("CountOverlapping aa in aaaa", StzEngineStringCountOverlapping(pStr, "aa"), 3)
StzEngineStringFree(pStr)
pStr = StzEngineStringFrom("abcabc")
Assert("CountOverlapping abc", StzEngineStringCountOverlapping(pStr, "abc"), 2)
StzEngineStringFree(pStr)

# --- Group 71: ReplaceAt ---
? "--- Group 71: ReplaceAt ---"
pStr = StzEngineStringFrom("Hello World")
pR = StzEngineStringReplaceAt(pStr, 5, 1, "-")
Assert("ReplaceAt space->dash", StzEngineStringData(pR), "Hello-World")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 72: CharFrequency ---
? "--- Group 72: CharFrequency ---"
pStr = StzEngineStringFrom("aab")
pR = StzEngineStringCharFrequency(pStr)
cFreq = StzEngineStringData(pR)
Assert("CharFrequency contains a:2", substr(cFreq, "a:2") > 0, true)
Assert("CharFrequency contains b:1", substr(cFreq, "b:1") > 0, true)
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 73: ContainsAnyOf, ContainsAllOf ---
? "--- Group 73: ContainsAnyOf, ContainsAllOf ---"
pStr = StzEngineStringFrom("hello")
Assert("ContainsAnyOf vowels", StzEngineStringContainsAnyOf(pStr, "aeiou"), 1)
Assert("ContainsAnyOf xyz", StzEngineStringContainsAnyOf(pStr, "xyz"), 0)
Assert("ContainsAllOf helo", StzEngineStringContainsAllOf(pStr, "helo"), 1)
Assert("ContainsAllOf heloz", StzEngineStringContainsAllOf(pStr, "heloz"), 0)
StzEngineStringFree(pStr)

# --- Group 74: Foldcase ---
? "--- Group 74: Foldcase ---"
pStr = StzEngineStringFrom("Hello WORLD")
pR = StzEngineStringFoldcase(pStr)
Assert("Foldcase Hello WORLD", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 75: CenterPad ---
? "--- Group 75: CenterPad ---"
pStr = StzEngineStringFrom("hi")
pR = StzEngineStringCenterPad(pStr, 6, "-")
Assert("CenterPad hi to 6 with -", StzEngineStringData(pR), "--hi--")
StzEngineStringFree(pR)
pR2 = StzEngineStringCenterPad(pStr, 7, "*")
Assert("CenterPad hi to 7 with *", StzEngineStringData(pR2), "**hi***")
StzEngineStringFree(pR2)
StzEngineStringFree(pStr)

# --- Group 76: OnlyLetters, OnlyDigits ---
? "--- Group 76: OnlyLetters, OnlyDigits ---"
pStr = StzEngineStringFrom("h3ll0 w0rld!")
pR = StzEngineStringOnlyLetters(pStr)
Assert("OnlyLetters from h3ll0 w0rld!", StzEngineStringData(pR), "hllwrld")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("a1b2c3")
pR = StzEngineStringOnlyDigits(pStr)
Assert("OnlyDigits from a1b2c3", StzEngineStringData(pR), "123")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 77: RemoveWhitespace ---
? "--- Group 77: RemoveWhitespace ---"
pStr = StzEngineStringFrom("h e l l o")
pR = StzEngineStringRemoveWhitespace(pStr)
Assert("RemoveWhitespace", StzEngineStringData(pR), "hello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 78: CountWords, NthWord ---
? "--- Group 78: CountWords, NthWord ---"
pStr = StzEngineStringFrom("hello world foo")
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

pStr = StzEngineStringFrom("  hello  ")
Assert("CountWords leading/trailing spaces", StzEngineStringCountWords(pStr), 1)
StzEngineStringFree(pStr)

# --- Group 79: CharsBetween ---
? "--- Group 79: CharsBetween ---"
pStr = StzEngineStringFrom("abcdef")
pR = StzEngineStringCharsBetween(pStr, 1, 4)
Assert("CharsBetween 1..4 = cd", StzEngineStringData(pR), "cd")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 80: IsAlphanumeric ---
? "--- Group 80: IsAlphanumeric ---"
pStr = StzEngineStringFrom("hello123")
Assert("IsAlphanumeric hello123", StzEngineStringIsAlphanumeric(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello 123")
Assert("IsAlphanumeric with space", StzEngineStringIsAlphanumeric(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello!")
Assert("IsAlphanumeric with punct", StzEngineStringIsAlphanumeric(pStr), 0)
StzEngineStringFree(pStr)

# --- Group 81: Ljust, Rjust ---
? "--- Group 81: Ljust, Rjust ---"
pStr = StzEngineStringFrom("hi")
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
? "--- Group 82: Indent, Dedent ---"
pStr = StzEngineStringFrom("line1" + char(10) + "line2")
pR = StzEngineStringIndent(pStr, 4)
cIndented = StzEngineStringData(pR)
Assert("Indent starts with spaces", left(cIndented, 4), "    ")
Assert("Indent contains indented line2", substr(cIndented, "    line2") > 0, true)
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("    hello" + char(10) + "    world")
pR = StzEngineStringDedent(pStr)
cDedented = StzEngineStringData(pR)
Assert("Dedent removes common indent", left(cDedented, 5), "hello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# --- Group 83: CamelCase, SnakeCase, KebabCase ---
? "--- Group 83: CamelCase, SnakeCase, KebabCase ---"
pStr = StzEngineStringFrom("hello world")
pR = StzEngineStringToCamelCase(pStr)
Assert("CamelCase hello world", StzEngineStringData(pR), "helloWorld")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("helloWorld")
pR = StzEngineStringToSnakeCase(pStr)
Assert("SnakeCase helloWorld", StzEngineStringData(pR), "hello_world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello_world")
pR = StzEngineStringToKebabCase(pStr)
Assert("KebabCase hello_world", StzEngineStringData(pR), "hello-world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("MyClassName")
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

? "--- Group 84: Partition/RPartition ---"

pStr = StzEngineStringFrom("hello:world:foo")
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

? "--- Group 85: Squeeze/IsDigit/Interleave ---"

pStr = StzEngineStringFrom("heeellooo")
pR = StzEngineStringSqueeze(pStr)
Assert("Squeeze heeellooo", StzEngineStringData(pR), "helo")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("aabbcc")
pR = StzEngineStringSqueeze(pStr)
Assert("Squeeze aabbcc", StzEngineStringData(pR), "abc")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("12345")
Assert("IsDigit 12345", StzEngineStringIsDigit(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("123a5")
Assert("IsDigit 123a5", StzEngineStringIsDigit(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("")
Assert("IsDigit empty", StzEngineStringIsDigit(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abc")
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

? "--- Group 86: StripChars/KeepChars/Replace2 ---"

pStr = StzEngineStringFrom("hello world!")
pR = StzEngineStringStripChars(pStr, "lo")
Assert("StripChars remove lo", StzEngineStringData(pR), "he wrd!")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("programming")
pR = StzEngineStringStripChars(pStr, "aeiou")
Assert("StripChars vowels", StzEngineStringData(pR), "prgrmmng")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello world!")
pR = StzEngineStringKeepChars(pStr, "lo")
Assert("KeepChars lo", StzEngineStringData(pR), "llool")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello world")
pR = StzEngineStringReplace2(pStr, "hello", "hi", "world", "earth")
Assert("Replace2 two subs", StzEngineStringData(pR), "hi earth")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 87: Surround, ReplaceAnyChar, CountAnyChar
# ==============================================================

? "--- Group 87: Surround/ReplaceAnyChar/CountAnyChar ---"

pStr = StzEngineStringFrom("hello")
pR = StzEngineStringSurround(pStr, "[", "]")
Assert("Surround hello", StzEngineStringData(pR), "[hello]")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
pR = StzEngineStringSurround(pStr, "<<", ">>")
Assert("Surround hello <<>>", StzEngineStringData(pR), "<<hello>>")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
pR = StzEngineStringReplaceAnyChar(pStr, "lo", "*")
Assert("ReplaceAnyChar lo->*", StzEngineStringData(pR), "he***")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello world!")
Assert("CountAnyChar aeiou", StzEngineStringCountAnyChar(pStr, "aeiou"), 3)
Assert("CountAnyChar lo", StzEngineStringCountAnyChar(pStr, "lo"), 5)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 88: Rotate / RepeatToLength / RemoveBetween / IsBlank / ToPascalCase
# ==============================================================

? ""
? "--- Group 88: Rotate / RepeatToLength / RemoveBetween / IsBlank / ToPascalCase ---"

pStr = StzEngineStringFrom("abcde")
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

pStr = StzEngineStringFrom("abc")
pR = StzEngineStringRepeatToLength(pStr, 7)
Assert("RepeatToLength 7", StzEngineStringData(pR), "abcabca")
StzEngineStringFree(pR)
pR = StzEngineStringRepeatToLength(pStr, 1)
Assert("RepeatToLength 1", StzEngineStringData(pR), "a")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello [world] end")
pR = StzEngineStringRemoveBetween(pStr, "[", "]")
Assert("RemoveBetween []", StzEngineStringData(pR), "hello  end")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("   ")
Assert("IsBlank spaces", StzEngineStringIsBlank(pStr), 1)
StzEngineStringFree(pStr)
pStr = StzEngineStringFrom("")
Assert("IsBlank empty", StzEngineStringIsBlank(pStr), 1)
StzEngineStringFree(pStr)
pStr = StzEngineStringFrom(" a ")
Assert("IsBlank not blank", StzEngineStringIsBlank(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello_world")
pR = StzEngineStringToPascalCase(pStr)
Assert("ToPascalCase snake", StzEngineStringData(pR), "HelloWorld")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)
pStr = StzEngineStringFrom("my-kebab-case")
pR = StzEngineStringToPascalCase(pStr)
Assert("ToPascalCase kebab", StzEngineStringData(pR), "MyKebabCase")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 89: IsIdentifier / ReplaceBetween / ContainsOnly / CapitalizeWords / SwapChars
# ==============================================================

? ""
? "--- Group 89: IsIdentifier / ReplaceBetween / ContainsOnly / CapitalizeWords / SwapChars ---"

pStr = StzEngineStringFrom("hello_world")
Assert("IsIdentifier valid", StzEngineStringIsIdentifier(pStr), 1)
StzEngineStringFree(pStr)
pStr = StzEngineStringFrom("_private")
Assert("IsIdentifier underscore start", StzEngineStringIsIdentifier(pStr), 1)
StzEngineStringFree(pStr)
pStr = StzEngineStringFrom("3invalid")
Assert("IsIdentifier digit start", StzEngineStringIsIdentifier(pStr), 0)
StzEngineStringFree(pStr)
pStr = StzEngineStringFrom("has space")
Assert("IsIdentifier space", StzEngineStringIsIdentifier(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello [world] end")
pR = StzEngineStringReplaceBetween(pStr, "[", "]", "REPLACED")
Assert("ReplaceBetween []", StzEngineStringData(pR), "hello REPLACED end")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("aabbcc")
Assert("ContainsOnly abc", StzEngineStringContainsOnly(pStr, "abc"), 1)
Assert("ContainsOnly ab", StzEngineStringContainsOnly(pStr, "ab"), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello world")
pR = StzEngineStringCapitalizeWords(pStr)
Assert("CapitalizeWords", StzEngineStringData(pR), "Hello World")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abcde")
pR = StzEngineStringSwapChars(pStr, 0, 4)
Assert("SwapChars 0,4", StzEngineStringData(pR), "ebcda")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 90: EncodeHex / DecodeHex / ReverseWords / CollapseSpaces
# ==============================================================

? ""
? "--- Group 90: EncodeHex / DecodeHex / ReverseWords / CollapseSpaces ---"

pStr = StzEngineStringFrom("Hi")
pR = StzEngineStringEncodeHex(pStr)
Assert("EncodeHex Hi", StzEngineStringData(pR), "4869")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("4869")
pR = StzEngineStringDecodeHex(pStr)
Assert("DecodeHex 4869", StzEngineStringData(pR), "Hi")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello world foo")
pR = StzEngineStringReverseWords(pStr)
Assert("ReverseWords", StzEngineStringData(pR), "foo world hello")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("  hello   world  ")
pR = StzEngineStringCollapseSpaces(pStr)
Assert("CollapseSpaces", StzEngineStringData(pR), "hello world")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 91: IsAnagram / Mask / CountRuns / HammingDistance
# ==============================================================

? ""
? "--- Group 91: IsAnagram / Mask / CountRuns / HammingDistance ---"

pStr1 = StzEngineStringFrom("listen")
pStr2 = StzEngineStringFrom("silent")
Assert("IsAnagram listen/silent", StzEngineStringIsAnagram(pStr1, pStr2), 1)
StzEngineStringFree(pStr2)
pStr2 = StzEngineStringFrom("hello")
Assert("IsAnagram listen/hello", StzEngineStringIsAnagram(pStr1, pStr2), 0)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr = StzEngineStringFrom("hello@mail.com")
pR = StzEngineStringMask(pStr, "*", 2)
Assert("Mask keep 2", StzEngineStringData(pR), "he**********om")
StzEngineStringFree(pR)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("aabbbcc")
Assert("CountRuns aabbbcc", StzEngineStringCountRuns(pStr), 3)
StzEngineStringFree(pStr)

pStr1 = StzEngineStringFrom("karolin")
pStr2 = StzEngineStringFrom("kathrin")
Assert("HammingDistance", StzEngineStringHammingDistance(pStr1, pStr2), 3)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

# ==============================================================
#  GROUP 92: RemoveVowels / OnlyVowels / IsPangram / Ngram / NgramCount
# ==============================================================

? ""
? "--- Group 92: RemoveVowels / OnlyVowels / IsPangram / Ngram / NgramCount ---"

pStr = StzEngineStringFrom("Hello World")
pResult = StzEngineStringRemoveVowels(pStr)
Assert("RemoveVowels Hello World", StzEngineStringData(pResult), "Hll Wrld")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello World")
pResult = StzEngineStringOnlyVowels(pStr)
Assert("OnlyVowels Hello World", StzEngineStringData(pResult), "eoo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("The quick brown fox jumps over the lazy dog")
Assert("IsPangram true", StzEngineStringIsPangram(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello World")
Assert("IsPangram false", StzEngineStringIsPangram(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
pResult = StzEngineStringNgram(pStr, 2, 0)
Assert("Ngram(hello,2,0)", StzEngineStringData(pResult), "he")
StzEngineStringFree(pResult)
pResult = StzEngineStringNgram(pStr, 2, 3)
Assert("Ngram(hello,2,3)", StzEngineStringData(pResult), "lo")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
Assert("NgramCount(hello,2)", StzEngineStringNgramCount(pStr, 2), 4)
Assert("NgramCount(hello,3)", StzEngineStringNgramCount(pStr, 3), 3)
Assert("NgramCount(hello,5)", StzEngineStringNgramCount(pStr, 5), 1)
Assert("NgramCount(hello,6)", StzEngineStringNgramCount(pStr, 6), 0)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 93: CountConsonants / ToSentenceCase / IsBalanced / Slug / Chunk
# ==============================================================

? ""
? "--- Group 93: CountConsonants / ToSentenceCase / IsBalanced / Slug / Chunk ---"

pStr = StzEngineStringFrom("Hello World")
Assert("CountConsonants Hello World", StzEngineStringCountConsonants(pStr), 7)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hELLO WORLD")
pResult = StzEngineStringToSentenceCase(pStr)
Assert("ToSentenceCase", StzEngineStringData(pResult), "Hello world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("(hello [world])")
Assert("IsBalanced true", StzEngineStringIsBalanced(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("(hello [world)")
Assert("IsBalanced false", StzEngineStringIsBalanced(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello World! This is a Test")
pResult = StzEngineStringSlug(pStr)
Assert("Slug", StzEngineStringData(pResult), "hello-world-this-is-a-test")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abcdefgh")
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

? ""
? "--- Group 94: CountVowels / LongestRun / TrimChars / IsEmailLike / CamelToWords ---"

pStr = StzEngineStringFrom("Hello World")
Assert("CountVowels Hello World", StzEngineStringCountVowels(pStr), 3)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("aabbbcccc")
Assert("LongestRun aabbbcccc", StzEngineStringLongestRun(pStr), 4)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("***hello***")
pResult = StzEngineStringTrimChars(pStr, "*")
Assert("TrimChars ***hello***", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("user@example.com")
Assert("IsEmailLike valid", StzEngineStringIsEmailLike(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("not-an-email")
Assert("IsEmailLike invalid", StzEngineStringIsEmailLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("camelCaseString")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords", StzEngineStringData(pResult), "camel Case String")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# ==============================================================
#  GROUP 95: Extended Edge-Case Tests
# ==============================================================

? ""
? "--- Group 95: Extended Edge-Case Tests ---"

# --- RemoveVowels edge cases ---
pStr = StzEngineStringFrom("AEIOU")
pResult = StzEngineStringRemoveVowels(pStr)
Assert("RemoveVowels all-uppercase-vowels", StzEngineStringData(pResult), "")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("bcdfg")
pResult = StzEngineStringRemoveVowels(pStr)
Assert("RemoveVowels no-vowels", StzEngineStringData(pResult), "bcdfg")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- OnlyVowels edge cases ---
pStr = StzEngineStringFrom("bcdfg")
pResult = StzEngineStringOnlyVowels(pStr)
Assert("OnlyVowels no-vowels empty", StzEngineStringSize(pResult), 0)
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("AEiOu")
pResult = StzEngineStringOnlyVowels(pStr)
Assert("OnlyVowels mixed case", StzEngineStringData(pResult), "AEiOu")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsPangram edge cases ---
pStr = StzEngineStringFrom("abcdefghijklmnopqrstuvwxyz")
Assert("IsPangram lowercase only", StzEngineStringIsPangram(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
Assert("IsPangram uppercase only", StzEngineStringIsPangram(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abcdefghijklmnopqrstuvwxy")
Assert("IsPangram missing z", StzEngineStringIsPangram(pStr), 0)
StzEngineStringFree(pStr)

# --- Ngram edge cases ---
pStr = StzEngineStringFrom("ab")
pResult = StzEngineStringNgram(pStr, 3, 0)
Assert("Ngram too-short returns null", IsNULL(pResult), true)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
pResult = StzEngineStringNgram(pStr, 1, 4)
Assert("Ngram single-char last", StzEngineStringData(pResult), "o")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- NgramCount edge cases ---
pStr = StzEngineStringFrom("")
Assert("NgramCount empty", StzEngineStringNgramCount(pStr, 2), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("a")
Assert("NgramCount single-char size=1", StzEngineStringNgramCount(pStr, 1), 1)
Assert("NgramCount single-char size=2", StzEngineStringNgramCount(pStr, 2), 0)
StzEngineStringFree(pStr)

# --- CountConsonants edge cases ---
pStr = StzEngineStringFrom("aeiou AEIOU")
Assert("CountConsonants no-consonants", StzEngineStringCountConsonants(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("BCDFG")
Assert("CountConsonants uppercase", StzEngineStringCountConsonants(pStr), 5)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("123!@#")
Assert("CountConsonants non-alpha", StzEngineStringCountConsonants(pStr), 0)
StzEngineStringFree(pStr)

# --- ToSentenceCase edge cases ---
pStr = StzEngineStringFrom("")
pResult = StzEngineStringToSentenceCase(pStr)
Assert("ToSentenceCase empty", StzEngineStringSize(pResult), 0)
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("A")
pResult = StzEngineStringToSentenceCase(pStr)
Assert("ToSentenceCase single char", StzEngineStringData(pResult), "A")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("   hello")
pResult = StzEngineStringToSentenceCase(pStr)
Assert("ToSentenceCase leading spaces", StzEngineStringData(pResult), "   Hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsBalanced edge cases ---
pStr = StzEngineStringFrom("")
Assert("IsBalanced empty", StzEngineStringIsBalanced(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("no brackets here")
Assert("IsBalanced no brackets", StzEngineStringIsBalanced(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("((()))")
Assert("IsBalanced nested parens", StzEngineStringIsBalanced(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom(")(")
Assert("IsBalanced reversed", StzEngineStringIsBalanced(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("{[}]")
Assert("IsBalanced mismatched", StzEngineStringIsBalanced(pStr), 0)
StzEngineStringFree(pStr)

# --- Slug edge cases ---
pStr = StzEngineStringFrom("")
pResult = StzEngineStringSlug(pStr)
Assert("Slug empty", StzEngineStringSize(pResult), 0)
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("already-a-slug")
pResult = StzEngineStringSlug(pStr)
Assert("Slug already-slug", StzEngineStringData(pResult), "already-a-slug")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("Hello_World-Test")
pResult = StzEngineStringSlug(pStr)
Assert("Slug mixed separators", StzEngineStringData(pResult), "hello-world-test")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("  leading trailing  ")
pResult = StzEngineStringSlug(pStr)
Assert("Slug leading/trailing spaces", StzEngineStringData(pResult), "leading-trailing")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- Chunk edge cases ---
pStr = StzEngineStringFrom("abcdefgh")
pResult = StzEngineStringChunk(pStr, 3, 1)
Assert("Chunk middle", StzEngineStringData(pResult), "def")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abc")
pResult = StzEngineStringChunk(pStr, 3, 0)
Assert("Chunk exact fit", StzEngineStringData(pResult), "abc")
StzEngineStringFree(pResult)
pResult = StzEngineStringChunk(pStr, 3, 1)
Assert("Chunk past end returns null", IsNULL(pResult), true)
StzEngineStringFree(pStr)

# --- CountVowels edge cases ---
pStr = StzEngineStringFrom("")
Assert("CountVowels empty", StzEngineStringCountVowels(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("AeIoU")
Assert("CountVowels mixed case", StzEngineStringCountVowels(pStr), 5)
StzEngineStringFree(pStr)

# --- LongestRun edge cases ---
pStr = StzEngineStringFrom("")
Assert("LongestRun empty", StzEngineStringLongestRun(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("aaaaaaa")
Assert("LongestRun all-same", StzEngineStringLongestRun(pStr), 7)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("a")
Assert("LongestRun single", StzEngineStringLongestRun(pStr), 1)
StzEngineStringFree(pStr)

# --- TrimChars edge cases ---
pStr = StzEngineStringFrom("hello")
pResult = StzEngineStringTrimChars(pStr, "*")
Assert("TrimChars nothing to trim", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("***")
pResult = StzEngineStringTrimChars(pStr, "*")
Assert("TrimChars all trimmed", StzEngineStringSize(pResult), 0)
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("--hello--world--")
pResult = StzEngineStringTrimChars(pStr, "-")
Assert("TrimChars hyphens", StzEngineStringData(pResult), "hello--world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsEmailLike edge cases ---
pStr = StzEngineStringFrom("a@b.c")
Assert("IsEmailLike minimal valid", StzEngineStringIsEmailLike(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("user@.com")
Assert("IsEmailLike dot at start", StzEngineStringIsEmailLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("user@domain.")
Assert("IsEmailLike dot at end", StzEngineStringIsEmailLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("user@@domain.com")
Assert("IsEmailLike double at", StzEngineStringIsEmailLike(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("first.last@sub.domain.org")
Assert("IsEmailLike complex valid", StzEngineStringIsEmailLike(pStr), 1)
StzEngineStringFree(pStr)

# --- CamelToWords edge cases ---
pStr = StzEngineStringFrom("HTMLParser")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords acronym", StzEngineStringData(pResult), "HTML Parser")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("simple")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords no-camel", StzEngineStringData(pResult), "simple")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("AString")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords PascalCase", StzEngineStringData(pResult), "AString")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("getHTTPSConnection")
pResult = StzEngineStringCamelToWords(pStr)
Assert("CamelToWords mixed", StzEngineStringData(pResult), "get HTTPS Connection")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- Rotate edge cases ---
pStr = StzEngineStringFrom("hello")
pResult = StzEngineStringRotate(pStr, 0)
Assert("Rotate by 0", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
pResult = StzEngineStringRotate(pStr, 5)
Assert("Rotate full length", StzEngineStringData(pResult), "hello")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
pResult = StzEngineStringRotate(pStr, -1)
Assert("Rotate right by 1", StzEngineStringData(pResult), "ohell")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- RepeatToLength edge cases ---
pStr = StzEngineStringFrom("ab")
pResult = StzEngineStringRepeatToLength(pStr, 5)
Assert("RepeatToLength ab->5", StzEngineStringData(pResult), "ababa")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("hello")
pResult = StzEngineStringRepeatToLength(pStr, 3)
Assert("RepeatToLength truncate", StzEngineStringData(pResult), "hel")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- RemoveBetween edge cases ---
pStr = StzEngineStringFrom("hello (world) there")
pResult = StzEngineStringRemoveBetween(pStr, "(", ")")
Assert("RemoveBetween parens", StzEngineStringData(pResult), "hello  there")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("no delimiters here")
pResult = StzEngineStringRemoveBetween(pStr, "[", "]")
Assert("RemoveBetween no match", StzEngineStringData(pResult), "no delimiters here")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsBlank edge cases ---
pStr = StzEngineStringFrom("")
Assert("IsBlank empty", StzEngineStringIsBlank(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("   ")
Assert("IsBlank spaces", StzEngineStringIsBlank(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom(" a ")
Assert("IsBlank with char", StzEngineStringIsBlank(pStr), 0)
StzEngineStringFree(pStr)

# --- ToPascalCase edge cases ---
pStr = StzEngineStringFrom("hello world")
pResult = StzEngineStringToPascalCase(pStr)
Assert("ToPascalCase basic", StzEngineStringData(pResult), "HelloWorld")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("one_two_three")
pResult = StzEngineStringToPascalCase(pStr)
Assert("ToPascalCase underscores", StzEngineStringData(pResult), "OneTwoThree")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsIdentifier edge cases ---
pStr = StzEngineStringFrom("_private")
Assert("IsIdentifier underscore start", StzEngineStringIsIdentifier(pStr), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("123abc")
Assert("IsIdentifier digit start", StzEngineStringIsIdentifier(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("")
Assert("IsIdentifier empty", StzEngineStringIsIdentifier(pStr), 0)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("valid_name123")
Assert("IsIdentifier alnum+underscore", StzEngineStringIsIdentifier(pStr), 1)
StzEngineStringFree(pStr)

# --- ReplaceBetween edge cases ---
pStr = StzEngineStringFrom("say [hello] friend")
pResult = StzEngineStringReplaceBetween(pStr, "[", "]", "world")
Assert("ReplaceBetween brackets", StzEngineStringData(pResult), "say [world] friend")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- ContainsOnly edge cases ---
pStr = StzEngineStringFrom("0123456789")
Assert("ContainsOnly digits", StzEngineStringContainsOnly(pStr, "0123456789"), 1)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("abc123")
Assert("ContainsOnly digits fail", StzEngineStringContainsOnly(pStr, "0123456789"), 0)
StzEngineStringFree(pStr)

# --- CapitalizeWords edge cases ---
pStr = StzEngineStringFrom("hello world")
pResult = StzEngineStringCapitalizeWords(pStr)
Assert("CapitalizeWords basic", StzEngineStringData(pResult), "Hello World")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("HELLO")
pResult = StzEngineStringCapitalizeWords(pStr)
Assert("CapitalizeWords already upper", StzEngineStringData(pResult), "HELLO")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- SwapChars edge cases ---
pStr = StzEngineStringFrom("abcde")
pResult = StzEngineStringSwapChars(pStr, 0, 4)
Assert("SwapChars first/last", StzEngineStringData(pResult), "ebcda")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- EncodeHex / DecodeHex roundtrip ---
pStr = StzEngineStringFrom("Hello")
pHex = StzEngineStringEncodeHex(pStr)
Assert("EncodeHex Hello", StzEngineStringData(pHex), "48656c6c6f")
pBack = StzEngineStringDecodeHex(pHex)
Assert("DecodeHex roundtrip", StzEngineStringData(pBack), "Hello")
StzEngineStringFree(pBack)
StzEngineStringFree(pHex)
StzEngineStringFree(pStr)

# --- ReverseWords edge cases ---
pStr = StzEngineStringFrom("one")
pResult = StzEngineStringReverseWords(pStr)
Assert("ReverseWords single word", StzEngineStringData(pResult), "one")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("a b c d e")
pResult = StzEngineStringReverseWords(pStr)
Assert("ReverseWords many", StzEngineStringData(pResult), "e d c b a")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- CollapseSpaces edge cases ---
pStr = StzEngineStringFrom("   hello   world   ")
pResult = StzEngineStringCollapseSpaces(pStr)
Assert("CollapseSpaces heavy", StzEngineStringData(pResult), "hello world")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- IsAnagram edge cases ---
pStr1 = StzEngineStringFrom("listen")
pStr2 = StzEngineStringFrom("silent")
Assert("IsAnagram listen/silent", StzEngineStringIsAnagram(pStr1, pStr2), 1)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr1 = StzEngineStringFrom("hello")
pStr2 = StzEngineStringFrom("world")
Assert("IsAnagram hello/world", StzEngineStringIsAnagram(pStr1, pStr2), 0)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr1 = StzEngineStringFrom("abc")
pStr2 = StzEngineStringFrom("abcd")
Assert("IsAnagram diff length", StzEngineStringIsAnagram(pStr1, pStr2), 0)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

# --- Mask edge cases ---
pStr = StzEngineStringFrom("1234567890")
pResult = StzEngineStringMask(pStr, "*", 4)
Assert("Mask credit-like", StzEngineStringData(pResult), "1234******")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

pStr = StzEngineStringFrom("ab")
pResult = StzEngineStringMask(pStr, "#", 4)
Assert("Mask short string", StzEngineStringData(pResult), "ab")
StzEngineStringFree(pResult)
StzEngineStringFree(pStr)

# --- HammingDistance edge cases ---
pStr1 = StzEngineStringFrom("abc")
pStr2 = StzEngineStringFrom("abc")
Assert("HammingDistance same", StzEngineStringHammingDistance(pStr1, pStr2), 0)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

pStr1 = StzEngineStringFrom("abc")
pStr2 = StzEngineStringFrom("xyz")
Assert("HammingDistance all diff", StzEngineStringHammingDistance(pStr1, pStr2), 3)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr1)

# ==============================================================
#  SUMMARY
# ==============================================================

? ""
? "======================================================"
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
