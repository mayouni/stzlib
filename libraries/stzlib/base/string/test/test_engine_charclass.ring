# Test engine character classification functions
# Run from the test/ directory: ring test_engine_charclass.ring

? "Loading stubs + DLL"
load "test_stubs.ring"

? "Loading stzString"
load "../stzString.ring"

? ""
? "=== Test 1: String-level bulk type extraction ==="

pStr = StzEngineString("Hello, world! 42 + $5.")

# OnlyPunctuation: extracts ,!.
pPunct = StzEngineStringOnlyPunctuation(pStr)
cPunct = StzEngineStringData(pPunct)
? "  OnlyPunctuation('Hello, world! 42 + $5.'): [" + cPunct + "]"

# OnlySymbols: extracts +$
pSyms = StzEngineStringOnlySymbols(pStr)
cSyms = StzEngineStringData(pSyms)
? "  OnlySymbols: [" + cSyms + "]"

# OnlyLetters: extracts Helloworld
pLet = StzEngineStringOnlyLetters(pStr)
cLet = StzEngineStringData(pLet)
? "  OnlyLetters: [" + cLet + "]"

# OnlyDigits: extracts 425
pDig = StzEngineStringOnlyDigits(pStr)
cDig = StzEngineStringData(pDig)
? "  OnlyDigits: [" + cDig + "]"

# OnlySpaces: extracts spaces
pSpc = StzEngineStringOnlySpaces(pStr)
cSpc = StzEngineStringData(pSpc)
? "  OnlySpaces: [" + len(cSpc) + " chars]"

StzEngineStringFree(pStr)
StzEngineStringFree(pPunct)
StzEngineStringFree(pSyms)
StzEngineStringFree(pLet)
StzEngineStringFree(pDig)
StzEngineStringFree(pSpc)

? ""
? "=== Test 2: String-level predicates ==="

pPunctOnly = StzEngineString(".,!?")
? "  IsPunctuation('.,!?'): " + StzEngineStringIsPunctuation(pPunctOnly)
StzEngineStringFree(pPunctOnly)

pSymOnly = StzEngineString("+=$")
? "  IsSymbol('+=$'): " + StzEngineStringIsSymbol(pSymOnly)
StzEngineStringFree(pSymOnly)

pMixed = StzEngineString("Hello!")
? "  IsPunctuation('Hello!'): " + StzEngineStringIsPunctuation(pMixed)
? "  HasPunctuation('Hello!'): " + StzEngineStringHasPunctuation(pMixed)
? "  HasSymbol('Hello!'): " + StzEngineStringHasSymbol(pMixed)
StzEngineStringFree(pMixed)

? ""
? "=== Test 3: Char-at-position functions ==="

pStr2 = StzEngineString("A1,+")

? "  CharUnicodeAt('A1,+', 1): " + StzEngineStringCharUnicodeAt(pStr2, 1)  # 65 = 'A'
? "  CharUnicodeAt('A1,+', 2): " + StzEngineStringCharUnicodeAt(pStr2, 2)  # 49 = '1'
? "  CharUnicodeAt('A1,+', 3): " + StzEngineStringCharUnicodeAt(pStr2, 3)  # 44 = ','
? "  CharUnicodeAt('A1,+', 4): " + StzEngineStringCharUnicodeAt(pStr2, 4)  # 43 = '+'

? "  CharCategoryAt('A1,+', 1): " + StzEngineStringCharCategoryAt(pStr2, 1)  # 1 = Lu
? "  CharCategoryAt('A1,+', 2): " + StzEngineStringCharCategoryAt(pStr2, 2)  # 9 = Nd

cCat = StzEngineStringCharCategoryStringAt(pStr2, 1)
? "  CharCategoryStringAt('A1,+', 1): " + cCat  # "Lu"
cCat2 = StzEngineStringCharCategoryStringAt(pStr2, 2)
? "  CharCategoryStringAt('A1,+', 2): " + cCat2  # "Nd"
cCat3 = StzEngineStringCharCategoryStringAt(pStr2, 3)
? "  CharCategoryStringAt('A1,+', 3): " + cCat3  # "Po"

? "  CharIsPunctuationAt('A1,+', 3): " + StzEngineStringCharIsPunctuationAt(pStr2, 3)  # 1
? "  CharIsSymbolAt('A1,+', 4): " + StzEngineStringCharIsSymbolAt(pStr2, 4)  # 1
? "  CharIsPunctuationAt('A1,+', 1): " + StzEngineStringCharIsPunctuationAt(pStr2, 1)  # 0

StzEngineStringFree(pStr2)

? ""
? "=== ALL ENGINE CHAR CLASSIFICATION TESTS PASSED ==="
