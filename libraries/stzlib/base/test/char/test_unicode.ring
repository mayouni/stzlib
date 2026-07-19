# Test Unicode correctness across domain classes
# Verifies multi-byte character handling (Arabic, CJK, emoji-like sequences)
# Run from the test/ directory: ring test_unicode.ring

? "Loading stubs + DLL"
#ERR Error (C22) : Function redefinition, function is already defined!

# BOOTSTRAP NOTE
# Loads the real library, not test_stubs.ring: this probe reaches
# stzString.Update(), which calls the inherited _NNLGuardUpdate() on
# stzObject. A method on a parent class cannot be stubbed from outside it,
# and loading stzObject on TOP of the stub collides on every shared global.
# Stub OR library, never a mix.
load "../../stzBase.ring"
# (the individual string-module loads that used to follow are gone --
#  stzBase.ring already provides every one of them, and loading both is a
#  wall of C22/C26 redefinitions.)

? "Loading classes"
nPass = 0
nFail = 0

? ""
? "=== Unicode: stzString Core ==="

# Arabic string: 5 chars, each 2 bytes in UTF-8
cArabic = "mrhba"
# Use actual Arabic: marhaba
cArabic = StzChar(1605) + StzChar(1585) + StzChar(1581) + StzChar(1576) + StzChar(1575)
oStr = new stzString(cArabic)

# NumberOfChars should be 5 (not 10 bytes)
nChars = oStr.NumberOfChars()
if nChars = 5
    ? "  Arabic NumberOfChars(5): PASS"
    nPass++
else
    ? "  Arabic NumberOfChars(5): FAIL [" + nChars + "]"
    nFail++
ok

# NthChar should return full char, not single byte
cFirst = oStr.NthChar(1)
if cFirst = StzChar(1605)
    ? "  Arabic NthChar(1): PASS"
    nPass++
else
    ? "  Arabic NthChar(1): FAIL"
    nFail++
ok

cLast = oStr.NthChar(5)
if cLast = StzChar(1575)
    ? "  Arabic NthChar(5): PASS"
    nPass++
else
    ? "  Arabic NthChar(5): FAIL"
    nFail++
ok

? ""
? "=== Unicode: stzStringCaseChanger ==="

# German with umlauts: uppercase/lowercase
cGerman = StzChar(252) + "ber"   # uber with u-umlaut
oCase = new stzStringCaseChanger(cGerman)
cUpper = oCase.Uppercased()
if cUpper = StzChar(220) + "BER"
    ? "  German Uppercased: PASS"
    nPass++
else
    ? "  German Uppercased: FAIL [" + cUpper + "]"
    nFail++
ok

# French accented
cFrench = StzChar(233) + "t" + StzChar(233)   # ete with accents
oCase2 = new stzStringCaseChanger(cFrench)
cUpper2 = oCase2.Uppercased()
if cUpper2 = StzChar(201) + "T" + StzChar(201)
    ? "  French Uppercased: PASS"
    nPass++
else
    ? "  French Uppercased: FAIL [" + cUpper2 + "]"
    nFail++
ok

? ""
? "=== Unicode: stzStringFinder ==="

# Find in mixed ASCII+Arabic
cMixed = "hello " + StzChar(1605) + StzChar(1585) + StzChar(1581) + StzChar(1576) + StzChar(1575) + " world"
oFinder = new stzStringFinder(cMixed)

bContains = oFinder.Contains("world")
if bContains = 1
    ? "  Contains 'world' in mixed: PASS"
    nPass++
else
    ? "  Contains 'world' in mixed: FAIL"
    nFail++
ok

# "hello " (6) + 5 Arabic chars + " " (1) = 12, so "world" at char 13
nFirst = oFinder.FindFirst("world")
if nFirst = 13
    ? "  FindFirst 'world' at pos 13: PASS"
    nPass++
else
    ? "  FindFirst 'world' at pos 13: FAIL [" + nFirst + "]"
    nFail++
ok

? ""
? "=== Unicode: stzStringGetter ==="

cChinese = StzChar(20320) + StzChar(22909) + StzChar(19990) + StzChar(30028)  # nihao shijie
oGet = new stzStringGetter(cChinese)

cFirst = oGet.FirstChar()
if cFirst = StzChar(20320)
    ? "  CJK FirstChar: PASS"
    nPass++
else
    ? "  CJK FirstChar: FAIL"
    nFail++
ok

cLast = oGet.LastChar()
if cLast = StzChar(30028)
    ? "  CJK LastChar: PASS"
    nPass++
else
    ? "  CJK LastChar: FAIL"
    nFail++
ok

cSection = oGet.Section(2, 3)
if cSection = StzChar(22909) + StzChar(19990)
    ? "  CJK Section(2,3): PASS"
    nPass++
else
    ? "  CJK Section(2,3): FAIL [" + cSection + "]"
    nFail++
ok

? ""
? "=== Unicode: stzStringDuplicates ==="

cDup = StzChar(1605) + StzChar(1585) + StzChar(1605)  # mim-ra-mim (mim duplicated)
oDup = new stzStringDuplicates(cDup)

acDups = oDup.DuplicatedChars()
if len(acDups) = 1 and acDups[1] = StzChar(1605)
    ? "  Arabic DuplicatedChars: PASS"
    nPass++
else
    ? "  Arabic DuplicatedChars: FAIL [count=" + len(acDups) + "]"
    nFail++
ok

nUnique = oDup.NumberOfUniqueChars()
if nUnique = 2
    ? "  Arabic UniqueChars(2): PASS"
    nPass++
else
    ? "  Arabic UniqueChars(2): FAIL [" + nUnique + "]"
    nFail++
ok

? ""
? "=== Unicode: stzStringConcat ==="

cBase = StzChar(20320) + StzChar(22909)  # nihao
oConcat = new stzStringConcat(cBase)
oConcat.RepeatNTimes(3)
cRepeated = oConcat.Content()
oCheck = new stzString(cRepeated)
nLen = oCheck.NumberOfChars()
if nLen = 6
    ? "  CJK Repeat(3) length 6: PASS"
    nPass++
else
    ? "  CJK Repeat(3) length 6: FAIL [" + nLen + "]"
    nFail++
ok

? ""
? "=== Unicode: stzStringSplitter ==="

cSplit = StzChar(1605) + " " + StzChar(1585) + " " + StzChar(1581)
oSplit = new stzStringSplitter(cSplit)
aParts = oSplit.Split(" ")
if len(aParts) = 3 and aParts[1] = StzChar(1605) and aParts[3] = StzChar(1581)
    ? "  Arabic Split by space: PASS"
    nPass++
else
    ? "  Arabic Split by space: FAIL [parts=" + len(aParts) + "]"
    nFail++
ok

? ""
? "=== Unicode: stzStringTrimmer ==="

cTrimMe = "  " + StzChar(233) + "t" + StzChar(233) + "  "
oTrim = new stzStringTrimmer(cTrimMe)
cTrimmed = oTrim.Trimmed()
if cTrimmed = StzChar(233) + "t" + StzChar(233)
    ? "  French Trimmed: PASS"
    nPass++
else
    ? "  French Trimmed: FAIL [" + cTrimmed + "]"
    nFail++
ok

? ""
? "=== Unicode: stzStringRandomizer ==="

cRandSrc = StzChar(20320) + StzChar(22909) + StzChar(19990) + StzChar(30028)
oRand = new stzStringRandomizer(cRandSrc)

# Shuffled should preserve char count
cShuffled = oRand.Shuffled()
oShCheck = new stzString(cShuffled)
if oShCheck.NumberOfChars() = 4
    ? "  CJK Shuffled length(4): PASS"
    nPass++
else
    ? "  CJK Shuffled length(4): FAIL [" + oShCheck.NumberOfChars() + "]"
    nFail++
ok

# RandomChar should be a full CJK char
cRC = oRand.RandomChar()
oRC = new stzString(cRC)
if oRC.NumberOfChars() = 1
    ? "  CJK RandomChar is 1 char: PASS"
    nPass++
else
    ? "  CJK RandomChar is 1 char: FAIL [" + oRC.NumberOfChars() + "]"
    nFail++
ok

? ""
? "=== Unicode: stzStringWalker ==="

cWalk = StzChar(1605) + StzChar(1585) + StzChar(1581)
oWalk = new stzStringWalker(cWalk)

cAt1 = oWalk.CharAt(1)
cAt3 = oWalk.CharAt(3)
if cAt1 = StzChar(1605) and cAt3 = StzChar(1581)
    ? "  Arabic CharAt(1,3): PASS"
    nPass++
else
    ? "  Arabic CharAt(1,3): FAIL"
    nFail++
ok

acFromTo = oWalk.CharsFromTo(1, 3)
if len(acFromTo) = 3 and acFromTo[1] = StzChar(1605) and acFromTo[3] = StzChar(1581)
    ? "  Arabic CharsFromTo(1,3): PASS"
    nPass++
else
    ? "  Arabic CharsFromTo(1,3): FAIL [count=" + len(acFromTo) + "]"
    nFail++
ok

? ""
? "=== Unicode: stzStringExtractor ==="

cExtSrc = StzChar(20320) + StzChar(22909) + StzChar(19990) + StzChar(30028)
oExt = new stzStringExtractor(cExtSrc)
cExtracted = oExt.ExtractSection(2, 3)
oRemain = new stzString(oExt.Content())
if cExtracted = StzChar(22909) + StzChar(19990) and oRemain.NumberOfChars() = 2
    ? "  CJK ExtractSection(2,3): PASS"
    nPass++
else
    ? "  CJK ExtractSection(2,3): FAIL [" + cExtracted + "] remain=" + oRemain.NumberOfChars()
    nFail++
ok

#-----------------------------------------------#
#   SUMMARY                                     #
#-----------------------------------------------#

? ""
? "=== RESULTS: " + nPass + " passed, " + nFail + " failed ==="
if nFail = 0
    ? "=== ALL UNICODE TESTS PASSED ==="
else
    ? "=== SOME UNICODE TESTS FAILED ==="
ok
