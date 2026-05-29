# Regression test covering core stzString operations and the
# composition-pattern submodules. Mirrors what was done for stzList
# during M-S2.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzString regression tests ==="

# ============================================================
# Core stzString
# ============================================================
? ""
? "--- stzString core ---"

o = new stzString("Hello, World!")

nTtl++
if o.NumberOfChars() = 13
	nPsd++
	? "  PASS: NumberOfChars = 13"
else
	nFld++
	? "  FAIL: NumberOfChars (got " + o.NumberOfChars() + ")"
ok

nTtl++
if o.Content() = "Hello, World!"
	nPsd++
	? "  PASS: Content"
else
	nFld++
	? "  FAIL: Content"
ok

# Empty string
o2 = new stzString("")
nTtl++
if o2.IsEmpty() = 1
	nPsd++
	? "  PASS: IsEmpty on empty"
else
	nFld++
	? "  FAIL: IsEmpty"
ok

nTtl++
if o.IsEmpty() = 0
	nPsd++
	? "  PASS: IsEmpty false on non-empty"
else
	nFld++
	? "  FAIL: IsEmpty false"
ok

# ============================================================
# Finder
# ============================================================
? ""
? "--- stzStringFinder ---"

oF = new stzString("abc xyz abc xyz abc")

nTtl++
if oF.FindFirst("abc") = 1
	nPsd++
	? "  PASS: FindFirst('abc') = 1"
else
	nFld++
	? "  FAIL: FindFirst (got " + oF.FindFirst("abc") + ")"
ok

nTtl++
if oF.FindLast("abc") = 17
	nPsd++
	? "  PASS: FindLast('abc') = 17"
else
	nFld++
	? "  FAIL: FindLast (got " + oF.FindLast("abc") + ")"
ok

anAll = oF.FindAll("abc")
nTtl++
if isList(anAll) and len(anAll) = 3 and anAll[1] = 1 and anAll[3] = 17
	nPsd++
	? "  PASS: FindAll('abc') = [1,9,17]"
else
	nFld++
	? "  FAIL: FindAll (got " + @@(anAll) + ")"
ok

nTtl++
if oF.NumberOfOccurrence("abc") = 3
	nPsd++
	? "  PASS: NumberOfOccurrence = 3"
else
	nFld++
	? "  FAIL: NumberOfOccurrence"
ok

nTtl++
if oF.Contains("xyz") = 1
	nPsd++
	? "  PASS: Contains('xyz')"
else
	nFld++
	? "  FAIL: Contains"
ok

# Case insensitive
oF2 = new stzString("Hello HELLO hello")
anCI = oF2.FindAllCS("hello", 0)
nTtl++
if isList(anCI) and len(anCI) = 3
	nPsd++
	? "  PASS: FindAllCS case-insensitive = 3 matches"
else
	nFld++
	? "  FAIL: FindAllCS CI (got " + @@(anCI) + ")"
ok

# ============================================================
# LeadTrail (StartsWith/EndsWith)
# ============================================================
? ""
? "--- stzStringLeadTrail ---"

oL = new stzString("hello world")

nTtl++
if oL.StartsWith("hello") = 1
	nPsd++
	? "  PASS: StartsWith('hello')"
else
	nFld++
	? "  FAIL: StartsWith"
ok

nTtl++
if oL.EndsWith("world") = 1
	nPsd++
	? "  PASS: EndsWith('world')"
else
	nFld++
	? "  FAIL: EndsWith"
ok

nTtl++
if oL.StartsWith("world") = 0
	nPsd++
	? "  PASS: StartsWith negative"
else
	nFld++
	? "  FAIL: StartsWith negative"
ok

# ============================================================
# Replacer
# ============================================================
? ""
? "--- stzStringReplacer ---"

oRep = new stzString("foo bar foo baz foo")
oRep.Replace("foo", "X")
nTtl++
if oRep.Content() = "X bar X baz X"
	nPsd++
	? "  PASS: Replace replaces all"
else
	nFld++
	? "  FAIL: Replace (got '" + oRep.Content() + "')"
ok

oRep2 = new stzString("abc abc abc")
oRep2.ReplaceFirst("abc", "X")
nTtl++
if oRep2.Content() = "X abc abc"
	nPsd++
	? "  PASS: ReplaceFirst"
else
	nFld++
	? "  FAIL: ReplaceFirst (got '" + oRep2.Content() + "')"
ok

oRep3 = new stzString("abc abc abc")
oRep3.ReplaceLast("abc", "X")
nTtl++
if oRep3.Content() = "abc abc X"
	nPsd++
	? "  PASS: ReplaceLast"
else
	nFld++
	? "  FAIL: ReplaceLast (got '" + oRep3.Content() + "')"
ok

# ============================================================
# Remover
# ============================================================
? ""
? "--- stzStringRemover ---"

oRm = new stzString("hello world")
oRm.Remove("o")
nTtl++
if oRm.Content() = "hell wrld"
	nPsd++
	? "  PASS: Remove removes all"
else
	nFld++
	? "  FAIL: Remove (got '" + oRm.Content() + "')"
ok

oRm2 = new stzString("abc abc abc")
oRm2.RemoveFirst("abc")
nTtl++
if oRm2.Content() = " abc abc"
	nPsd++
	? "  PASS: RemoveFirst"
else
	nFld++
	? "  FAIL: RemoveFirst (got '" + oRm2.Content() + "')"
ok

# ============================================================
# Trimmer
# ============================================================
? ""
? "--- stzStringTrimmer ---"

oT = new stzString("   hello   ")
oT.Trim()
nTtl++
if oT.Content() = "hello"
	nPsd++
	? "  PASS: Trim strips both ends"
else
	nFld++
	? "  FAIL: Trim (got '" + oT.Content() + "')"
ok

oT2 = new stzString("   hello   ")
oT2.TrimLeft()
nTtl++
if oT2.Content() = "hello   "
	nPsd++
	? "  PASS: TrimLeft"
else
	nFld++
	? "  FAIL: TrimLeft (got '" + oT2.Content() + "')"
ok

oT3 = new stzString("   hello   ")
oT3.TrimRight()
nTtl++
if oT3.Content() = "   hello"
	nPsd++
	? "  PASS: TrimRight"
else
	nFld++
	? "  FAIL: TrimRight (got '" + oT3.Content() + "')"
ok

# ============================================================
# Splitter
# ============================================================
? ""
? "--- stzStringSplitter ---"

oS = new stzString("a,b,c,d")
aParts = oS.Split(",")
nTtl++
if isList(aParts) and len(aParts) = 4 and aParts[1] = "a" and aParts[4] = "d"
	nPsd++
	? "  PASS: Split(',') = [a,b,c,d]"
else
	nFld++
	? "  FAIL: Split (got " + @@(aParts) + ")"
ok

oS2 = new stzString("hello world foo")
aWords = oS2.Split(" ")
nTtl++
if isList(aWords) and len(aWords) = 3 and aWords[1] = "hello" and aWords[3] = "foo"
	nPsd++
	? "  PASS: Split space"
else
	nFld++
	? "  FAIL: Split space (got " + @@(aWords) + ")"
ok

# ============================================================
# Inserter
# ============================================================
? ""
? "--- stzStringInserter ---"

oI = new stzString("hello world")
oI.InsertBefore(7, "beautiful ")
nTtl++
if oI.Content() = "hello beautiful world"
	nPsd++
	? "  PASS: InsertBefore"
else
	nFld++
	? "  FAIL: InsertBefore (got '" + oI.Content() + "')"
ok

oI2 = new stzString("hello world")
oI2.InsertAfter(5, " beautiful")
nTtl++
if oI2.Content() = "hello beautiful world"
	nPsd++
	? "  PASS: InsertAfter"
else
	nFld++
	? "  FAIL: InsertAfter (got '" + oI2.Content() + "')"
ok

# ============================================================
# Bounder / Sections
# ============================================================
? ""
? "--- stzStringBounder / Sections ---"

oB = new stzString("0123456789")
# INDEX_BASE=1: position 1 = '0', position 3 = '2', position 7 = '6'
# So Section(3,7) returns characters at positions 3..7 = "23456"
cSec = oB.Section(3, 7)
nTtl++
if cSec = "23456"
	nPsd++
	? "  PASS: Section(3,7) = '23456' (1-based)"
else
	nFld++
	? "  FAIL: Section (got '" + cSec + "')"
ok

cRng = oB.Range(3, 5)
nTtl++
if cRng = "23456"
	nPsd++
	? "  PASS: Range(3,5) = '23456' (start=3 length=5)"
else
	nFld++
	? "  FAIL: Range (got '" + cRng + "')"
ok

# ============================================================
# Case changer
# ============================================================
? ""
? "--- stzStringCaseChanger ---"

oC = new stzString("Hello World")
cLow = oC.Lowercased()
nTtl++
if cLow = "hello world"
	nPsd++
	? "  PASS: Lowercased"
else
	nFld++
	? "  FAIL: Lowercased (got '" + cLow + "')"
ok

cUp = oC.Uppercased()
nTtl++
if cUp = "HELLO WORLD"
	nPsd++
	? "  PASS: Uppercased"
else
	nFld++
	? "  FAIL: Uppercased (got '" + cUp + "')"
ok

# ============================================================
# Checker
# ============================================================
? ""
? "--- stzStringChecker ---"

oCk1 = new stzString("hello")
nTtl++
if oCk1.IsAlphaString() = 1
	nPsd++
	? "  PASS: IsAlphaString on 'hello'"
else
	nFld++
	? "  FAIL: IsAlphaString"
ok

oCk2 = new stzString("12345")
nTtl++
if oCk2.IsNumericString() = 1
	nPsd++
	? "  PASS: IsNumericString on '12345'"
else
	nFld++
	? "  FAIL: IsNumericString"
ok

# ============================================================
# Reverse
# ============================================================
? ""
? "--- Reverse ---"

oRev = new stzString("hello")
cRev = oRev.Reversed()
nTtl++
if cRev = "olleh"
	nPsd++
	? "  PASS: Reversed = 'olleh'"
else
	nFld++
	? "  FAIL: Reversed (got '" + cRev + "')"
ok

# ============================================================
# Unicode handling
# ============================================================
? ""
? "--- Unicode handling ---"

oU = new stzString("héllo wörld")
nTtl++
# Codepoint count should be 11 not byte count
if oU.NumberOfChars() = 11
	nPsd++
	? "  PASS: Unicode codepoint count = 11"
else
	nFld++
	? "  FAIL: Unicode codepoint count (got " + oU.NumberOfChars() + ")"
ok

oU2 = new stzString("café")
cUpU = oU2.Uppercased()
nTtl++
if cUpU = "CAFÉ"
	nPsd++
	? "  PASS: Unicode uppercase 'café' -> 'CAFÉ'"
else
	nFld++
	? "  FAIL: Unicode upper (got '" + cUpU + "')"
ok

? ""
? "=========================="
? "Total: " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok
