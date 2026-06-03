# Test domain classes batch 5: Numbers, Duplicates, Extractor,
# Randomizer, Crypto
# Run from the test/ directory: ring test_domains5.ring

? "Loading stubs + DLL"
#ERR Error (E9) : Can't open file ../stzString.ring

load "test_stubs.ring"

? "Loading classes"
load "../../string/stzString.ring"
load "../../string/stzStringFinder.ring"
load "../../string/stzStringReplacer.ring"
load "../../string/stzStringNumbers.ring"
load "../../string/stzStringDuplicates.ring"
load "../../string/stzStringExtractor.ring"
load "../../string/stzStringRandomizer.ring"
load "../../string/stzStringCrypto.ring"
nPass = 0
nFail = 0

#-----------------------------------------------#
#   stzStringNumbers                            #
#-----------------------------------------------#

? ""
? "=== Test: stzStringNumbers ==="

oNums = new stzStringNumbers("price is 42 and tax is 8")
anNums = oNums.Numbers()
if len(anNums) = 2 and anNums[1] = 42 and anNums[2] = 8
    ? "  Numbers: PASS"
    nPass++
else
    ? "  Numbers: FAIL [" + len(anNums) + " numbers]"
    nFail++
ok

if oNums.NumberOfNumbers() = 2
    ? "  NumberOfNumbers: PASS"
    nPass++
else
    ? "  NumberOfNumbers: FAIL"
    nFail++
ok

if oNums.ContainsNumbers() = 1
    ? "  ContainsNumbers: PASS"
    nPass++
else
    ? "  ContainsNumbers: FAIL"
    nFail++
ok

if oNums.SumOfNumbers() = 50
    ? "  SumOfNumbers: PASS"
    nPass++
else
    ? "  SumOfNumbers: FAIL [" + oNums.SumOfNumbers() + "]"
    nFail++
ok

if oNums.MaxNumber() = 42
    ? "  MaxNumber: PASS"
    nPass++
else
    ? "  MaxNumber: FAIL [" + oNums.MaxNumber() + "]"
    nFail++
ok

if oNums.MinNumber() = 8
    ? "  MinNumber: PASS"
    nPass++
else
    ? "  MinNumber: FAIL [" + oNums.MinNumber() + "]"
    nFail++
ok

if oNums.FirstNumber() = 42
    ? "  FirstNumber: PASS"
    nPass++
else
    ? "  FirstNumber: FAIL"
    nFail++
ok

if oNums.LastNumber() = 8
    ? "  LastNumber: PASS"
    nPass++
else
    ? "  LastNumber: FAIL"
    nFail++
ok

cNoNums = oNums.NumbersRemoved()
if cNoNums = "price is  and tax is "
    ? "  NumbersRemoved: PASS"
    nPass++
else
    ? "  NumbersRemoved: FAIL [" + cNoNums + "]"
    nFail++
ok

anPos = oNums.PositionsOfNumbers()
if len(anPos) = 2 and anPos[1] = 10 and anPos[2] = 24
    ? "  PositionsOfNumbers: PASS"
    nPass++
else
    ? "  PositionsOfNumbers: FAIL"
    nFail++
ok

# Float numbers
oNums2 = new stzStringNumbers("total 12.5 and 3.14")
anNums2 = oNums2.Numbers()
if len(anNums2) = 2
    ? "  Float Numbers: PASS [" + anNums2[1] + ", " + anNums2[2] + "]"
    nPass++
else
    ? "  Float Numbers: FAIL [" + len(anNums2) + " numbers]"
    nFail++
ok

# No numbers
oNums3 = new stzStringNumbers("hello world")
if oNums3.ContainsNumbers() = 0
    ? "  No Numbers: PASS"
    nPass++
else
    ? "  No Numbers: FAIL"
    nFail++
ok

#-----------------------------------------------#
#   stzStringDuplicates                         #
#-----------------------------------------------#

? ""
? "=== Test: stzStringDuplicates ==="

oDups = new stzStringDuplicates("aabbc")
acDups = oDups.DuplicatedChars()
if len(acDups) = 2  # a and b are duplicated
    ? "  DuplicatedChars: PASS"
    nPass++
else
    ? "  DuplicatedChars: FAIL [" + len(acDups) + "]"
    nFail++
ok

if oDups.HasDuplicatedChars() = 1
    ? "  HasDuplicatedChars: PASS"
    nPass++
else
    ? "  HasDuplicatedChars: FAIL"
    nFail++
ok

acUniq = oDups.UniqueChars()
if len(acUniq) = 3  # a, b, c
    ? "  UniqueChars: PASS"
    nPass++
else
    ? "  UniqueChars: FAIL [" + len(acUniq) + "]"
    nFail++
ok

if oDups.NumberOfUniqueChars() = 3
    ? "  NumberOfUniqueChars: PASS"
    nPass++
else
    ? "  NumberOfUniqueChars: FAIL"
    nFail++
ok

# Consecutive duplicates
oDups2 = new stzStringDuplicates("aabbcc")
if oDups2.HasConsecutiveDuplicates() = 1
    ? "  HasConsecutiveDuplicates: PASS"
    nPass++
else
    ? "  HasConsecutiveDuplicates: FAIL"
    nFail++
ok

cConsecRemoved = oDups2.ConsecutiveDuplicateCharsRemoved()
if cConsecRemoved = "abc"
    ? "  ConsecutiveDuplicateCharsRemoved: PASS"
    nPass++
else
    ? "  ConsecutiveDuplicateCharsRemoved: FAIL [" + cConsecRemoved + "]"
    nFail++
ok

# Remove all duplicates (keep first occurrence only)
oDups3 = new stzStringDuplicates("abcabc")
cAllDupRemoved = oDups3.AllDuplicateCharsRemoved()
if cAllDupRemoved = "abc"
    ? "  AllDuplicateCharsRemoved: PASS"
    nPass++
else
    ? "  AllDuplicateCharsRemoved: FAIL [" + cAllDupRemoved + "]"
    nFail++
ok

# No consecutive duplicates
oDups4 = new stzStringDuplicates("abcabc")
if oDups4.HasConsecutiveDuplicates() = 0
    ? "  NoConsecutiveDuplicates: PASS"
    nPass++
else
    ? "  NoConsecutiveDuplicates: FAIL"
    nFail++
ok

# Remove duplicate substring (keep first, remove rest)
oDups5 = new stzStringDuplicates("hello world hello")
cDedup = oDups5.DuplicateSubStringRemoved("hello")
if cDedup = "hello world "
    ? "  DuplicateSubStringRemoved: PASS"
    nPass++
else
    ? "  DuplicateSubStringRemoved: FAIL [" + cDedup + "]"
    nFail++
ok

#-----------------------------------------------#
#   stzStringExtractor                          #
#-----------------------------------------------#

? ""
? "=== Test: stzStringExtractor ==="

# ExtractSection
oExt = new stzStringExtractor("ABCDEFG")
cExtracted = oExt.ExtractSection(3, 5)
if cExtracted = "CDE" and oExt.Content() = "ABFG"
    ? "  ExtractSection: PASS"
    nPass++
else
    ? "  ExtractSection: FAIL [" + cExtracted + "] remain=[" + oExt.Content() + "]"
    nFail++
ok

# ExtractFirstChar
oExt2 = new stzStringExtractor("Hello")
cFirst = oExt2.ExtractFirstChar()
if cFirst = "H" and oExt2.Content() = "ello"
    ? "  ExtractFirstChar: PASS"
    nPass++
else
    ? "  ExtractFirstChar: FAIL [" + cFirst + "] remain=[" + oExt2.Content() + "]"
    nFail++
ok

# ExtractLastChar
oExt3 = new stzStringExtractor("Hello")
cLast = oExt3.ExtractLastChar()
if cLast = "o" and oExt3.Content() = "Hell"
    ? "  ExtractLastChar: PASS"
    nPass++
else
    ? "  ExtractLastChar: FAIL [" + cLast + "] remain=[" + oExt3.Content() + "]"
    nFail++
ok

# ExtractAll
oExt4 = new stzStringExtractor("content")
cExtAll = oExt4.ExtractAll()
if cExtAll = "content" and oExt4.Content() = ""
    ? "  ExtractAll: PASS"
    nPass++
else
    ? "  ExtractAll: FAIL"
    nFail++
ok

# ExtractFirst occurrence
oExt5 = new stzStringExtractor("one ring two ring")
cFirstOcc = oExt5.ExtractFirst("ring")
if cFirstOcc = "ring" and oExt5.Content() = "one  two ring"
    ? "  ExtractFirst: PASS"
    nPass++
else
    ? "  ExtractFirst: FAIL [" + cFirstOcc + "] remain=[" + oExt5.Content() + "]"
    nFail++
ok

# ExtractRange
oExt6 = new stzStringExtractor("ABCDEFG")
cRange = oExt6.ExtractRange(2, 3)
if cRange = "BCD" and oExt6.Content() = "AEFG"
    ? "  ExtractRange: PASS"
    nPass++
else
    ? "  ExtractRange: FAIL [" + cRange + "] remain=[" + oExt6.Content() + "]"
    nFail++
ok

#-----------------------------------------------#
#   stzStringRandomizer                         #
#-----------------------------------------------#

? ""
? "=== Test: stzStringRandomizer ==="

# Shuffle produces same chars, different order (or same if lucky)
oRand = new stzStringRandomizer("abcdef")
cShuffled = oRand.Shuffled()
nLen = len(cShuffled)
if nLen = 6
    ? "  Shuffled length: PASS"
    nPass++
else
    ? "  Shuffled length: FAIL [" + nLen + "]"
    nFail++
ok

# RandomChar returns a char from the string
oRand2 = new stzStringRandomizer("XYZ")
cRChar = oRand2.RandomChar()
if cRChar = "X" or cRChar = "Y" or cRChar = "Z"
    ? "  RandomChar: PASS [" + cRChar + "]"
    nPass++
else
    ? "  RandomChar: FAIL [" + cRChar + "]"
    nFail++
ok

# RandomChars returns n chars
acRChars = oRand2.RandomChars(3)
if len(acRChars) = 3
    ? "  RandomChars(3): PASS"
    nPass++
else
    ? "  RandomChars(3): FAIL [" + len(acRChars) + "]"
    nFail++
ok

# RandomSection returns correct length
oRand3 = new stzStringRandomizer("Hello World")
cRSec = oRand3.RandomSection(5)
if len(cRSec) = 5
    ? "  RandomSection(5): PASS [" + cRSec + "]"
    nPass++
else
    ? "  RandomSection(5): FAIL [" + len(cRSec) + "]"
    nFail++
ok

# RandomWord returns one of the words
oRand4 = new stzStringRandomizer("one two three")
cRWord = oRand4.RandomWord()
if cRWord = "one" or cRWord = "two" or cRWord = "three"
    ? "  RandomWord: PASS [" + cRWord + "]"
    nPass++
else
    ? "  RandomWord: FAIL [" + cRWord + "]"
    nFail++
ok

# WordsShuffled preserves word count
oRand5 = new stzStringRandomizer("one two three")
cWShuf = oRand5.WordsShuffled()
acWords = @split(cWShuf, " ")
if len(acWords) = 3
    ? "  WordsShuffled count: PASS"
    nPass++
else
    ? "  WordsShuffled count: FAIL [" + len(acWords) + "]"
    nFail++
ok

# RandomCased preserves length
oRand6 = new stzStringRandomizer("hello")
cRCased = oRand6.RandomCased()
if len(cRCased) = 5
    ? "  RandomCased length: PASS [" + cRCased + "]"
    nPass++
else
    ? "  RandomCased length: FAIL"
    nFail++
ok

#-----------------------------------------------#
#   stzStringCrypto (Engine-backed)             #
#-----------------------------------------------#

? ""
? "=== Test: stzStringCrypto ==="

# Caesar cipher (shift 3)
oCrypto = new stzStringCrypto("Hello World")
cCaesar = oCrypto.CaesarEncrypted(3)
if cCaesar = "Khoor Zruog"
    ? "  CaesarEncrypt(3): PASS"
    nPass++
else
    ? "  CaesarEncrypt(3): FAIL [" + cCaesar + "]"
    nFail++
ok

# Caesar decrypt (reverse of encrypt)
oCrypto2 = new stzStringCrypto("Khoor Zruog")
oCrypto2.CaesarDecrypt(3)
if oCrypto2.Content() = "Hello World"
    ? "  CaesarDecrypt(3): PASS"
    nPass++
else
    ? "  CaesarDecrypt(3): FAIL [" + oCrypto2.Content() + "]"
    nFail++
ok

# ROT13
oCrypto3 = new stzStringCrypto("Hello")
cRot = oCrypto3.ROT13ed()
if cRot = "Uryyb"
    ? "  ROT13: PASS"
    nPass++
else
    ? "  ROT13: FAIL [" + cRot + "]"
    nFail++
ok

# ROT13 is its own inverse
oCrypto4 = new stzStringCrypto("Uryyb")
cRot2 = oCrypto4.ROT13ed()
if cRot2 = "Hello"
    ? "  ROT13 inverse: PASS"
    nPass++
else
    ? "  ROT13 inverse: FAIL [" + cRot2 + "]"
    nFail++
ok

# Base64 encode
oCrypto5 = new stzStringCrypto("Hello World")
cB64 = oCrypto5.Base64Encoded()
if cB64 = "SGVsbG8gV29ybGQ="
    ? "  Base64Encode: PASS"
    nPass++
else
    ? "  Base64Encode: FAIL [" + cB64 + "]"
    nFail++
ok

# Base64 decode
oCrypto6 = new stzStringCrypto("SGVsbG8gV29ybGQ=")
cDecoded = oCrypto6.Base64Decoded()
if cDecoded = "Hello World"
    ? "  Base64Decode: PASS"
    nPass++
else
    ? "  Base64Decode: FAIL [" + cDecoded + "]"
    nFail++
ok

# Atbash cipher (a<->z, b<->y, etc.)
oCrypto7 = new stzStringCrypto("abc")
cAtb = oCrypto7.Atbashed()
if cAtb = "zyx"
    ? "  Atbash: PASS"
    nPass++
else
    ? "  Atbash: FAIL [" + cAtb + "]"
    nFail++
ok

# Hash returns a number
oCrypto8 = new stzStringCrypto("test")
nHash = oCrypto8.Hash()
if isNumber(nHash) and nHash != 0
    ? "  Hash: PASS [" + nHash + "]"
    nPass++
else
    ? "  Hash: FAIL"
    nFail++
ok

# Entropy returns a positive number for non-empty string
oCrypto9 = new stzStringCrypto("Hello World")
nEnt = oCrypto9.Entropy()
if isNumber(nEnt) and nEnt > 0
    ? "  Entropy: PASS [" + nEnt + "]"
    nPass++
else
    ? "  Entropy: FAIL"
    nFail++
ok

# XOR encrypt/decrypt roundtrip
oCrypto10 = new stzStringCrypto("Secret")
cXOR = oCrypto10.XOREncrypt("key")
cBack = new stzStringCrypto(cXOR)
cDecrypted = cBack.XORDecrypt("key")
if cDecrypted = "Secret"
    ? "  XOR roundtrip: PASS"
    nPass++
else
    ? "  XOR roundtrip: FAIL [" + cDecrypted + "]"
    nFail++
ok

#-----------------------------------------------#
#   SUMMARY                                     #
#-----------------------------------------------#

? ""
? "=== RESULTS: " + nPass + " passed, " + nFail + " failed ==="
if nFail = 0
    ? "=== ALL DOMAIN TESTS BATCH 5 PASSED ==="
else
    ? "=== SOME TESTS FAILED ==="
ok
