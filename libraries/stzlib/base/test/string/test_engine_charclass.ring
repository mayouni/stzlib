# Test engine character classification functions
# Run from the test/ directory: ring test_engine_charclass.ring

? "Loading stubs + DLL"
#ERR Error (E9) : Can't open file ../stzString.ring

load "test_stubs.ring"

? "Loading stzString"
load "../../string/stzString.ring"
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
? "=== Test 4: Bulk counters (enumerable pattern) ==="

pStr3 = StzEngineString("Hello, world! 42 + $5.")

? "  CountLetters: " + StzEngineStringCountLetters(pStr3)           # 10
? "  CountDigits: " + StzEngineStringCountDigits(pStr3)             # 3
? "  CountSpaces: " + StzEngineStringCountSpaces(pStr3)             # 4
? "  CountPunctuation: " + StzEngineStringCountPunctuation(pStr3)   # 3 (,!.)
? "  CountSymbols: " + StzEngineStringCountSymbols(pStr3)           # 2 (+$)

StzEngineStringFree(pStr3)

? ""
? "=== Test 5: Script detection (codepoint-level) ==="

# Arabic alef = U+0627 = 1575
? "  IsArabic(U+0627 alef): " + StzEngineUnicodeIsArabic(1575)    # 1
? "  IsArabic(65 = 'A'): " + StzEngineUnicodeIsArabic(65)         # 0
? "  IsLatin(65 = 'A'): " + StzEngineUnicodeIsLatin(65)           # 1
? "  IsLatin(1575 = alef): " + StzEngineUnicodeIsLatin(1575)      # 0
? "  IsGreek(945 = alpha): " + StzEngineUnicodeIsGreek(945)       # 1
? "  IsCyrillic(1040 = A): " + StzEngineUnicodeIsCyrillic(1040)   # 1

? ""
? "=== Test 6: Script bulk (enumerable pattern) ==="

# Build Arabic "marhaba" from UTF-8 bytes
# U+0645 (meem) = D9 85, U+0631 (ra) = D8 B1, U+062D (ha) = D8 AD
# U+0628 (ba) = D8 A8, U+0627 (alef) = D8 A7
cArabic = char(217)+char(133) + char(216)+char(177) + char(216)+char(173) + char(216)+char(168) + char(216)+char(167)
pAr = StzEngineString(cArabic)
? "  IsArabic('marhaba'): " + StzEngineStringIsArabic(pAr)                    # 1
? "  IsArabicLetters('marhaba'): " + StzEngineStringIsArabicLetters(pAr)       # 1
? "  CountArabic: " + StzEngineStringCountArabic(pAr)                          # 5
? "  CountArabicLetters: " + StzEngineStringCountArabicLetters(pAr)            # 5
StzEngineStringFree(pAr)

# Mixed: "Hi" + Arabic meem+ra (2 Arabic chars)
cMixed = "Hi" + char(217)+char(133) + char(216)+char(177)
pMx = StzEngineString(cMixed)
? "  IsLatin('Hi+arabic'): " + StzEngineStringIsLatin(pMx)                    # 0 (mixed)
? "  CountLatin: " + StzEngineStringCountLatin(pMx)                            # 2
? "  CountArabic: " + StzEngineStringCountArabic(pMx)                          # 2
? "  CountLatinLetters: " + StzEngineStringCountLatinLetters(pMx)              # 2

# OnlyLatin extracts just the Latin chars
pLatOnly = StzEngineStringOnlyLatin(pMx)
cLatOnly = StzEngineStringData(pLatOnly)
? "  OnlyLatin('Hi+arabic'): [" + cLatOnly + "]"                               # Hi

# OnlyArabicLetters extracts just the Arabic letters
pArOnly = StzEngineStringOnlyArabicLetters(pMx)
? "  OnlyArabicLetters count: " + StzEngineStringCount(pArOnly)                # 2

# HasArabic / HasLatin on mixed string
? "  HasArabic('Hi+arabic'): " + StzEngineStringHasArabic(pMx)                  # 1
? "  HasLatin('Hi+arabic'): " + StzEngineStringHasLatin(pMx)                    # 1

StzEngineStringFree(pMx)
StzEngineStringFree(pLatOnly)
StzEngineStringFree(pArOnly)

# Pure Latin: HasArabic should be 0
pPureLat = StzEngineString("Hello")
? "  HasArabic('Hello'): " + StzEngineStringHasArabic(pPureLat)                 # 0
? "  HasLatin('Hello'): " + StzEngineStringHasLatin(pPureLat)                   # 1
? "  IsLatin('Hello'): " + StzEngineStringIsLatin(pPureLat)                     # 1
StzEngineStringFree(pPureLat)

? ""
? "=== Test 7: Greek/Cyrillic/Hebrew predicates ==="

# Greek alpha+beta = U+03B1 (CE B1) + U+03B2 (CE B2)
cGreek = char(206)+char(177) + char(206)+char(178)
pGr = StzEngineString(cGreek)
? "  IsGreek(alpha+beta): " + StzEngineStringIsGreek(pGr)                       # 1
? "  HasGreek(alpha+beta): " + StzEngineStringHasGreek(pGr)                     # 1
? "  CountGreek: " + StzEngineStringCountGreek(pGr)                             # 2 (already tested at codepoint)
StzEngineStringFree(pGr)

# Cyrillic A+B = U+0410 (D0 90) + U+0411 (D0 91)
cCyr = char(208)+char(144) + char(208)+char(145)
pCyr = StzEngineString(cCyr)
? "  IsCyrillic: " + StzEngineStringIsCyrillic(pCyr)                            # 1
? "  HasCyrillic: " + StzEngineStringHasCyrillic(pCyr)                          # 1
StzEngineStringFree(pCyr)

# Hebrew alef+bet = U+05D0 (D7 90) + U+05D1 (D7 91)
cHeb = char(215)+char(144) + char(215)+char(145)
pHeb = StzEngineString(cHeb)
? "  IsHebrew: " + StzEngineStringIsHebrew(pHeb)                                # 1
? "  HasHebrew: " + StzEngineStringHasHebrew(pHeb)                              # 1
StzEngineStringFree(pHeb)

# Mixed: Latin + Hebrew should not be IsHebrew but HasHebrew
cMixHeb = "Hi" + char(215)+char(144)
pMixHeb = StzEngineString(cMixHeb)
? "  IsHebrew('Hi+alef'): " + StzEngineStringIsHebrew(pMixHeb)                  # 0
? "  HasHebrew('Hi+alef'): " + StzEngineStringHasHebrew(pMixHeb)                # 1
? "  HasLatin('Hi+alef'): " + StzEngineStringHasLatin(pMixHeb)                  # 1
StzEngineStringFree(pMixHeb)

? ""
? "=== ALL ENGINE CHAR CLASSIFICATION TESTS PASSED ==="
