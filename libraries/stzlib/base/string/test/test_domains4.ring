# Test domain classes batch 4: CaseChanger, Aligner, Lines, Words,
# Sections, Inserter, Comparator, Encoder

? "Loading DLL"
$cStzStringLib = "D:\GitHub\stzlib\libraries\stzlib\engine\zig-out\bin\stz_string.dll"
if fexists($cStzStringLib)
    $pStzStringHandle = LoadLib($cStzStringLib)
ok

? "Loading stubs"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\test\test_stubs.ring"

? "Loading classes"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzString.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringFinder.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringCaseChanger.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringAligner.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringLines.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringWords.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringSections.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringInserter.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringComparator.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringEncoder.ring"

nPass = 0
nFail = 0

#-----------------------------------------------#
#   stzStringCaseChanger                        #
#-----------------------------------------------#

? ""
? "=== Test: stzStringCaseChanger ==="

oCC = new stzStringCaseChanger("hello WORLD")
if oCC.Uppercased() = "HELLO WORLD"
    ? "  Uppercased: PASS"
    nPass++
else
    ? "  Uppercased: FAIL [" + oCC.Uppercased() + "]"
    nFail++
ok

oCC2 = new stzStringCaseChanger("HELLO WORLD")
if oCC2.Lowercased() = "hello world"
    ? "  Lowercased: PASS"
    nPass++
else
    ? "  Lowercased: FAIL [" + oCC2.Lowercased() + "]"
    nFail++
ok

oCC3 = new stzStringCaseChanger("hello world")
if oCC3.Capitalized() = "Hello world"
    ? "  Capitalized: PASS"
    nPass++
else
    ? "  Capitalized: FAIL [" + oCC3.Capitalized() + "]"
    nFail++
ok

oCC4 = new stzStringCaseChanger("hello world foo")
if oCC4.EachWordCapitalized() = "Hello World Foo"
    ? "  EachWordCapitalized: PASS"
    nPass++
else
    ? "  EachWordCapitalized: FAIL [" + oCC4.EachWordCapitalized() + "]"
    nFail++
ok

oCC5 = new stzStringCaseChanger("ABC")
if oCC5.IsUppercase() = 1
    ? "  IsUppercase: PASS"
    nPass++
else
    ? "  IsUppercase: FAIL"
    nFail++
ok

oCC6 = new stzStringCaseChanger("abc")
if oCC6.IsLowercase() = 1
    ? "  IsLowercase: PASS"
    nPass++
else
    ? "  IsLowercase: FAIL"
    nFail++
ok

oCC7 = new stzStringCaseChanger("Hello")
if oCC7.CaseToggled() = "hELLO"
    ? "  CaseToggled: PASS"
    nPass++
else
    ? "  CaseToggled: FAIL [" + oCC7.CaseToggled() + "]"
    nFail++
ok

#-----------------------------------------------#
#   stzStringAligner                            #
#-----------------------------------------------#

? ""
? "=== Test: stzStringAligner ==="

oAL = new stzStringAligner("hi")
cRight = oAL.AlignedRight(6, ".")
if cRight = "....hi"
    ? "  AlignedRight: PASS"
    nPass++
else
    ? "  AlignedRight: FAIL [" + cRight + "]"
    nFail++
ok

oAL2 = new stzStringAligner("hi")
cLeft = oAL2.AlignedLeft(6, ".")
if cLeft = "hi...."
    ? "  AlignedLeft: PASS"
    nPass++
else
    ? "  AlignedLeft: FAIL [" + cLeft + "]"
    nFail++
ok

oAL3 = new stzStringAligner("hi")
cCenter = oAL3.AlignedCenter(6, ".")
if cCenter = "..hi.."
    ? "  AlignedCenter: PASS"
    nPass++
else
    ? "  AlignedCenter: FAIL [" + cCenter + "]"
    nFail++
ok

oAL4 = new stzStringAligner("hi")
cPadL = oAL4.PaddedLeft(5, "*")
if cPadL = "***hi"
    ? "  PaddedLeft: PASS"
    nPass++
else
    ? "  PaddedLeft: FAIL [" + cPadL + "]"
    nFail++
ok

#-----------------------------------------------#
#   stzStringLines                              #
#-----------------------------------------------#

? ""
? "=== Test: stzStringLines ==="

cMultiLine = "alpha" + NL + "beta" + NL + "gamma"
oLines = new stzStringLines(cMultiLine)

if oLines.NumberOfLines() = 3
    ? "  NumberOfLines: PASS"
    nPass++
else
    ? "  NumberOfLines: FAIL [" + oLines.NumberOfLines() + "]"
    nFail++
ok

if oLines.FirstLine() = "alpha"
    ? "  FirstLine: PASS"
    nPass++
else
    ? "  FirstLine: FAIL [" + oLines.FirstLine() + "]"
    nFail++
ok

if oLines.LastLine() = "gamma"
    ? "  LastLine: PASS"
    nPass++
else
    ? "  LastLine: FAIL [" + oLines.LastLine() + "]"
    nFail++
ok

if oLines.NthLine(2) = "beta"
    ? "  NthLine(2): PASS"
    nPass++
else
    ? "  NthLine(2): FAIL [" + oLines.NthLine(2) + "]"
    nFail++
ok

aFirst2 = oLines.NFirstLines(2)
if len(aFirst2) = 2 and aFirst2[1] = "alpha" and aFirst2[2] = "beta"
    ? "  NFirstLines(2): PASS"
    nPass++
else
    ? "  NFirstLines(2): FAIL"
    nFail++
ok

aLast2 = oLines.NLastLines(2)
if len(aLast2) = 2 and aLast2[1] = "beta" and aLast2[2] = "gamma"
    ? "  NLastLines(2): PASS"
    nPass++
else
    ? "  NLastLines(2): FAIL"
    nFail++
ok

if oLines.LongestLine() = "alpha"  # alpha and gamma are both 5 chars, alpha is first
    ? "  LongestLine: PASS"
    nPass++
else
    ? "  LongestLine: FAIL [" + oLines.LongestLine() + "]"
    nFail++
ok

if oLines.ShortestLine() = "beta"
    ? "  ShortestLine: PASS"
    nPass++
else
    ? "  ShortestLine: FAIL [" + oLines.ShortestLine() + "]"
    nFail++
ok

# Lines with empty lines
cWithEmpty = "aaa" + NL + "" + NL + "bbb"
oLines2 = new stzStringLines(cWithEmpty)
if oLines2.HasEmptyLines() = 1
    ? "  HasEmptyLines: PASS"
    nPass++
else
    ? "  HasEmptyLines: FAIL"
    nFail++
ok

cNoEmpty = oLines2.EmptyLinesRemoved()
oLines3 = new stzStringLines(cNoEmpty)
if oLines3.NumberOfLines() = 2
    ? "  EmptyLinesRemoved: PASS"
    nPass++
else
    ? "  EmptyLinesRemoved: FAIL [" + oLines3.NumberOfLines() + " lines]"
    nFail++
ok

# Duplicate lines
cDup = "aaa" + NL + "bbb" + NL + "aaa"
oLines4 = new stzStringLines(cDup)
cDeduped = oLines4.DuplicateLinesRemoved()
oLines5 = new stzStringLines(cDeduped)
if oLines5.NumberOfLines() = 2
    ? "  DuplicateLinesRemoved: PASS"
    nPass++
else
    ? "  DuplicateLinesRemoved: FAIL [" + oLines5.NumberOfLines() + " lines]"
    nFail++
ok

# Lines containing
cSearch = "one ring" + NL + "two towers" + NL + "three rings"
oLines6 = new stzStringLines(cSearch)
cFound = oLines6.LineContaining("ring")
if cFound = "one ring"
    ? "  LineContaining: PASS"
    nPass++
else
    ? "  LineContaining: FAIL [" + cFound + "]"
    nFail++
ok

aFound = oLines6.LinesContaining("ring")
if len(aFound) = 2
    ? "  LinesContaining: PASS"
    nPass++
else
    ? "  LinesContaining: FAIL [" + len(aFound) + " lines]"
    nFail++
ok

# Reverse lines
cRev = oLines.LinesOrderReversed()
oLinesRev = new stzStringLines(cRev)
if oLinesRev.FirstLine() = "gamma" and oLinesRev.LastLine() = "alpha"
    ? "  LinesOrderReversed: PASS"
    nPass++
else
    ? "  LinesOrderReversed: FAIL"
    nFail++
ok

# Indent lines
cIndented = oLines.LinesIndented(3)
oLinesInd = new stzStringLines(cIndented)
if left(oLinesInd.FirstLine(), 3) = "   "
    ? "  LinesIndented: PASS"
    nPass++
else
    ? "  LinesIndented: FAIL"
    nFail++
ok

#-----------------------------------------------#
#   stzStringWords                              #
#-----------------------------------------------#

? ""
? "=== Test: stzStringWords ==="

oWords = new stzStringWords("the quick brown fox jumps over the lazy dog")

if oWords.NumberOfWords() = 9
    ? "  NumberOfWords: PASS"
    nPass++
else
    ? "  NumberOfWords: FAIL [" + oWords.NumberOfWords() + "]"
    nFail++
ok

if oWords.FirstWord() = "the"
    ? "  FirstWord: PASS"
    nPass++
else
    ? "  FirstWord: FAIL [" + oWords.FirstWord() + "]"
    nFail++
ok

if oWords.LastWord() = "dog"
    ? "  LastWord: PASS"
    nPass++
else
    ? "  LastWord: FAIL [" + oWords.LastWord() + "]"
    nFail++
ok

if oWords.NthWord(3) = "brown"
    ? "  NthWord(3): PASS"
    nPass++
else
    ? "  NthWord(3): FAIL [" + oWords.NthWord(3) + "]"
    nFail++
ok

cLongest = oWords.LongestWord()
if len(cLongest) = 5  # quick, brown, jumps all 5 chars; first wins
    ? "  LongestWord: PASS [" + cLongest + "]"
    nPass++
else
    ? "  LongestWord: FAIL [" + cLongest + "]"
    nFail++
ok

if oWords.ShortestWord() = "the"
    ? "  ShortestWord: PASS"
    nPass++
else
    ? "  ShortestWord: FAIL [" + oWords.ShortestWord() + "]"
    nFail++
ok

# Unique words (case-insensitive by default in UniqueWords)
aUnique = oWords.UniqueWords()
if len(aUnique) = 8  # "the" appears twice
    ? "  UniqueWords: PASS"
    nPass++
else
    ? "  UniqueWords: FAIL [" + len(aUnique) + "]"
    nFail++
ok

if oWords.ContainsWord("fox") = 1
    ? "  ContainsWord: PASS"
    nPass++
else
    ? "  ContainsWord: FAIL"
    nFail++
ok

if oWords.MostFrequentWord() = "the"
    ? "  MostFrequentWord: PASS"
    nPass++
else
    ? "  MostFrequentWord: FAIL [" + oWords.MostFrequentWord() + "]"
    nFail++
ok

aFirst3 = oWords.NFirstWords(3)
if len(aFirst3) = 3 and aFirst3[1] = "the" and aFirst3[3] = "brown"
    ? "  NFirstWords(3): PASS"
    nPass++
else
    ? "  NFirstWords(3): FAIL"
    nFail++
ok

aLast3 = oWords.NLastWords(3)
if len(aLast3) = 3 and aLast3[3] = "dog"
    ? "  NLastWords(3): PASS"
    nPass++
else
    ? "  NLastWords(3): FAIL"
    nFail++
ok

# ReplaceWord
oWords2 = new stzStringWords("I love cats and cats")
oWords2.ReplaceWord("cats", "dogs")
if oWords2.Content() = "I love dogs and dogs"
    ? "  ReplaceWord: PASS"
    nPass++
else
    ? "  ReplaceWord: FAIL [" + oWords2.Content() + "]"
    nFail++
ok

# RemoveWord
oWords3 = new stzStringWords("hello dear world dear")
oWords3.RemoveWord("dear")
if oWords3.Content() = "hello world"
    ? "  RemoveWord: PASS"
    nPass++
else
    ? "  RemoveWord: FAIL [" + oWords3.Content() + "]"
    nFail++
ok

#-----------------------------------------------#
#   stzStringSections                           #
#-----------------------------------------------#

? ""
? "=== Test: stzStringSections ==="

oSec = new stzStringSections("ABCDEFGHIJ")

if oSec.Section(3, 6) = "CDEF"
    ? "  Section(3,6): PASS"
    nPass++
else
    ? "  Section(3,6): FAIL [" + oSec.Section(3, 6) + "]"
    nFail++
ok

if oSec.Range(3, 4) = "CDEF"
    ? "  Range(3,4): PASS"
    nPass++
else
    ? "  Range(3,4): FAIL [" + oSec.Range(3, 4) + "]"
    nFail++
ok

# Multiple sections
aSecs = oSec.Sections([ [1,3], [5,7] ])
if len(aSecs) = 2 and aSecs[1] = "ABC" and aSecs[2] = "EFG"
    ? "  Sections: PASS"
    nPass++
else
    ? "  Sections: FAIL"
    nFail++
ok

# AntiSections
aAnti = oSec.AntiSections([ [3,5] ])
if len(aAnti) = 2 and aAnti[1] = "AB" and aAnti[2] = "FGHIJ"
    ? "  AntiSections: PASS"
    nPass++
else
    ? "  AntiSections: FAIL [" + len(aAnti) + " parts]"
    nFail++
ok

# RemoveSection
cRemoved = oSec.SectionRemoved(3, 5)
if cRemoved = "ABFGHIJ"
    ? "  SectionRemoved: PASS"
    nPass++
else
    ? "  SectionRemoved: FAIL [" + cRemoved + "]"
    nFail++
ok

# RemoveRange
cRangeRemoved = oSec.RangeRemoved(3, 3)
if cRangeRemoved = "ABFGHIJ"
    ? "  RangeRemoved: PASS"
    nPass++
else
    ? "  RangeRemoved: FAIL [" + cRangeRemoved + "]"
    nFail++
ok

# SectionBetween (content between positions, exclusive)
if oSec.SectionBetween(2, 5) = "CD"
    ? "  SectionBetween: PASS"
    nPass++
else
    ? "  SectionBetween: FAIL [" + oSec.SectionBetween(2, 5) + "]"
    nFail++
ok

#-----------------------------------------------#
#   stzStringInserter                           #
#-----------------------------------------------#

? ""
? "=== Test: stzStringInserter ==="

# InsertBefore position
oIns = new stzStringInserter("ABCDE")
oIns.InsertBefore(3, "XX")
if oIns.Content() = "ABXXCDE"
    ? "  InsertBefore(3): PASS"
    nPass++
else
    ? "  InsertBefore(3): FAIL [" + oIns.Content() + "]"
    nFail++
ok

# InsertAfter position
oIns2 = new stzStringInserter("ABCDE")
oIns2.InsertAfter(3, "XX")
if oIns2.Content() = "ABCXXDE"
    ? "  InsertAfter(3): PASS"
    nPass++
else
    ? "  InsertAfter(3): FAIL [" + oIns2.Content() + "]"
    nFail++
ok

# InsertBefore position 1 (prepend)
oIns3 = new stzStringInserter("World")
oIns3.InsertBefore(1, "Hello ")
if oIns3.Content() = "Hello World"
    ? "  InsertBefore(1): PASS"
    nPass++
else
    ? "  InsertBefore(1): FAIL [" + oIns3.Content() + "]"
    nFail++
ok

# InsertBeforeSubString
oIns4 = new stzStringInserter("one ring two ring")
oIns4.InsertBeforeSubString("ring", "<<")
if oIns4.Content() = "one <<ring two <<ring"
    ? "  InsertBeforeSubString: PASS"
    nPass++
else
    ? "  InsertBeforeSubString: FAIL [" + oIns4.Content() + "]"
    nFail++
ok

# InsertAfterSubString
oIns5 = new stzStringInserter("one ring two ring")
oIns5.InsertAfterSubString("ring", ">>")
if oIns5.Content() = "one ring>> two ring>>"
    ? "  InsertAfterSubString: PASS"
    nPass++
else
    ? "  InsertAfterSubString: FAIL [" + oIns5.Content() + "]"
    nFail++
ok

# InsertAfterFirst
oIns6 = new stzStringInserter("aa bb aa")
oIns6.InsertAfterFirst("aa", "XX")
if oIns6.Content() = "aaXX bb aa"
    ? "  InsertAfterFirst: PASS"
    nPass++
else
    ? "  InsertAfterFirst: FAIL [" + oIns6.Content() + "]"
    nFail++
ok

# InsertBeforeLast
oIns7 = new stzStringInserter("aa bb aa")
oIns7.InsertBeforeLast("aa", "YY")
if oIns7.Content() = "aa bb YYaa"
    ? "  InsertBeforeLast: PASS"
    nPass++
else
    ? "  InsertBeforeLast: FAIL [" + oIns7.Content() + "]"
    nFail++
ok

#-----------------------------------------------#
#   stzStringComparator                         #
#-----------------------------------------------#

? ""
? "=== Test: stzStringComparator ==="

oCmp = new stzStringComparator("Hello")

if oCmp.IsEqualTo("Hello") = 1
    ? "  IsEqualTo (same): PASS"
    nPass++
else
    ? "  IsEqualTo (same): FAIL"
    nFail++
ok

if oCmp.IsEqualTo("hello") = 0
    ? "  IsEqualTo (diff case): PASS"
    nPass++
else
    ? "  IsEqualTo (diff case): FAIL"
    nFail++
ok

if oCmp.IsEqualToCS("hello", 0) = 1
    ? "  IsEqualToCS case-insensitive: PASS"
    nPass++
else
    ? "  IsEqualToCS case-insensitive: FAIL"
    nFail++
ok

if oCmp.IsNotEqualTo("World") = 1
    ? "  IsNotEqualTo: PASS"
    nPass++
else
    ? "  IsNotEqualTo: FAIL"
    nFail++
ok

if oCmp.Compare("Hello") = 0
    ? "  Compare equal: PASS"
    nPass++
else
    ? "  Compare equal: FAIL [" + oCmp.Compare("Hello") + "]"
    nFail++
ok

if oCmp.Compare("Aello") = 1
    ? "  Compare greater: PASS"
    nPass++
else
    ? "  Compare greater: FAIL [" + oCmp.Compare("Aello") + "]"
    nFail++
ok

if oCmp.Compare("Zello") = -1
    ? "  Compare less: PASS"
    nPass++
else
    ? "  Compare less: FAIL [" + oCmp.Compare("Zello") + "]"
    nFail++
ok

if oCmp.Contains("ell") = 1
    ? "  Contains: PASS"
    nPass++
else
    ? "  Contains: FAIL"
    nFail++
ok

if oCmp.ContainsOneOfThese(["xyz", "llo"]) = 1
    ? "  ContainsOneOfThese: PASS"
    nPass++
else
    ? "  ContainsOneOfThese: FAIL"
    nFail++
ok

if oCmp.ContainsAllOfThese(["He", "lo"]) = 1
    ? "  ContainsAllOfThese: PASS"
    nPass++
else
    ? "  ContainsAllOfThese: FAIL"
    nFail++
ok

aDiff = oCmp.DiffWith("Hxllo")
if len(aDiff) = 1 and aDiff[1] = 2
    ? "  DiffWith: PASS"
    nPass++
else
    ? "  DiffWith: FAIL [" + len(aDiff) + " diffs]"
    nFail++
ok

if oCmp.IsEqualToOneOfThese(["World", "Hello", "Foo"]) = 1
    ? "  IsEqualToOneOfThese: PASS"
    nPass++
else
    ? "  IsEqualToOneOfThese: FAIL"
    nFail++
ok

#-----------------------------------------------#
#   stzStringEncoder                            #
#-----------------------------------------------#

? ""
? "=== Test: stzStringEncoder ==="

oEnc = new stzStringEncoder("AB")
cHex = oEnc.ToHex()
if upper(cHex) = "4142"
    ? "  ToHex: PASS"
    nPass++
else
    ? "  ToHex: FAIL [" + cHex + "]"
    nFail++
ok

oEnc2 = new stzStringEncoder("hello world")
cUrl = oEnc2.UrlEncoded()
if cUrl = "hello%20world"
    ? "  UrlEncoded: PASS"
    nPass++
else
    ? "  UrlEncoded: FAIL [" + cUrl + "]"
    nFail++
ok

oEnc3 = new stzStringEncoder("hello%20world")
cDecoded = oEnc3.UrlDecoded()
if cDecoded = "hello world"
    ? "  UrlDecoded: PASS"
    nPass++
else
    ? "  UrlDecoded: FAIL [" + cDecoded + "]"
    nFail++
ok

oEnc4 = new stzStringEncoder("A")
cBin = oEnc4.ToBinary()
if cBin = "01000001"
    ? "  ToBinary: PASS"
    nPass++
else
    ? "  ToBinary: FAIL [" + cBin + "]"
    nFail++
ok

oEnc5 = new stzStringEncoder("<b>hi</b>")
cHtml = oEnc5.HtmlEncoded()
if cHtml = "&lt;b&gt;hi&lt;/b&gt;"
    ? "  HtmlEncoded: PASS"
    nPass++
else
    ? "  HtmlEncoded: FAIL [" + cHtml + "]"
    nFail++
ok

oEnc6 = new stzStringEncoder("&lt;b&gt;hi&lt;/b&gt;")
cHtmlDec = oEnc6.HtmlDecoded()
if cHtmlDec = "<b>hi</b>"
    ? "  HtmlDecoded: PASS"
    nPass++
else
    ? "  HtmlDecoded: FAIL [" + cHtmlDec + "]"
    nFail++
ok

oEnc7 = new stzStringEncoder("abc")
cRev = oEnc7.Reversed()
if cRev = "cba"
    ? "  Reversed: PASS"
    nPass++
else
    ? "  Reversed: FAIL [" + cRev + "]"
    nFail++
ok

oEnc8 = new stzStringEncoder("AB")
cCodes = oEnc8.ToCharCodes()
if cCodes = "65 66"
    ? "  ToCharCodes: PASS"
    nPass++
else
    ? "  ToCharCodes: FAIL [" + cCodes + "]"
    nFail++
ok

oEnc9 = new stzStringEncoder("")
oEnc9.FromCharCodes("72 105")
if oEnc9.Content() = "Hi"
    ? "  FromCharCodes: PASS"
    nPass++
else
    ? "  FromCharCodes: FAIL [" + oEnc9.Content() + "]"
    nFail++
ok

oEnc10 = new stzStringEncoder("a.b")
cEsc = oEnc10.EscapedForRegex()
if cEsc = "a\.b"
    ? "  EscapedForRegex: PASS"
    nPass++
else
    ? "  EscapedForRegex: FAIL [" + cEsc + "]"
    nFail++
ok

#-----------------------------------------------#
#   SUMMARY                                     #
#-----------------------------------------------#

? ""
? "=== RESULTS: " + nPass + " passed, " + nFail + " failed ==="
if nFail = 0
    ? "=== ALL DOMAIN TESTS BATCH 4 PASSED ==="
else
    ? "=== SOME TESTS FAILED ==="
ok
