
#ERR Error (R3) : Calling Function without definition: stzenginestring

# BOOTSTRAP NOTE
# This file loads the real library rather than test_stubs.ring.
#
# The stub is a hand-written mirror of the string domain's globals (Q,
# StzRaise, CheckParams, IsListOfStrings, StzStringQ, ...). This file needs
# things the stub does not carry -- stzObject, for the inherited Update()
# guard, or stzStringFunc's condition normalisers -- and those real files
# define the very same globals, so loading both is a wall of C22/C26
# redefinitions. Stub OR library, never a mix.
#
# The other files here that stay on the stub are the ones whose isolation
# still genuinely holds.
load "../../../stzBase.ring"
? "=== Counter Tests ==="

# CountAnyChar
oCnt = new stzStringCounter("hello world")
? "CountAnyChar('lo'): " + oCnt.CountAnyChar("lo")

# CountLeadingChar
oCnt = new stzStringCounter("aaabcd")
? "CountLeadingChar('a'): " + oCnt.CountLeadingChar("a")
#--> 3

# CountTrailingChar
oCnt = new stzStringCounter("abcddd")
? "CountTrailingChar('d'): " + oCnt.CountTrailingChar("d")
#--> 3

# GraphemeCount
oCnt = new stzStringCounter("hello")
? "GraphemeCount('hello'): " + oCnt.GraphemeCount()
#--> 5

# CountMarks
oCnt = new stzStringCounter("hello")
? "CountMarks('hello'): " + oCnt.CountMarks()
#--> 0

# CountControls
oCnt = new stzStringCounter("hello")
? "CountControls('hello'): " + oCnt.CountControls()
#--> 0

? ""
? "=== Checker Tests (new) ==="

# ContainsChar
oChk = new stzStringChecker("hello")
? "ContainsChar('e'): " + oChk.ContainsChar("e")
#--> 1

oChk = new stzStringChecker("hello")
? "ContainsChar('z'): " + oChk.ContainsChar("z")
#--> 0

# IsControl
oChk = new stzStringChecker("hello")
? "IsControl('hello'): " + oChk.IsControl()
#--> 0

# HasMark
oChk = new stzStringChecker("hello")
? "HasMark('hello'): " + oChk.HasMark()
#--> 0

# CharIsSpaceAt
oChk = new stzStringChecker("hi there")
? "CharIsSpaceAt(3): " + oChk.CharIsSpaceAt(3)
#--> 1

? ""
? "=== Finder Tests (new) ==="

# IndexOfCS
oFnd = new stzStringFinder("hello world")
? "IndexOf('world'): " + oFnd.IndexOf("world")
#--> 7

# FindAllChar
oFnd = new stzStringFinder("hello")
aPos = oFnd.FindAllChar("l")
cPos = ""
_nPosLen_ = len(aPos)
for i = 1 to _nPosLen_
	if i > 1 cPos += "," ok
	cPos += ("" + aPos[i])
next
? "FindAllChar('l'): [" + cPos + "]"
#--> [3,4]

# BetweenNth
oFnd = new stzStringFinder("(a)(b)(c)")
? "BetweenNth('(',')',1): " + oFnd.BetweenNth("(", ")", 1)
#--> a

# CharsBetween (exclusive on both ends: chars strictly between positions 1 and 5)
oFnd = new stzStringFinder("hello world")
? "CharsBetween(1,5): " + oFnd.CharsBetween(1, 5)
#--> ell (positions 2,3,4)

? ""
? "=== CaseChanger Tests (new) ==="

# DecapitalizeFirst
oCC = new stzStringCaseChanger("Hello World")
? "FirstDecapitalized: " + oCC.FirstDecapitalized()
#--> hello World

? ""
? "=== Replacer Tests (new) ==="

# ReplaceAnyChar
oRpl = new stzStringReplacer("hello world")
? "AnyCharReplaced('lo','*'): " + oRpl.AnyCharReplaced("lo", "*")
#--> he*** w*r*d

# ReplaceBetween
oRpl = new stzStringReplacer("say (hello) please")
? "BetweenReplaced('(',')','HI'): " + oRpl.BetweenReplaced("(", ")", "HI")

# ReplaceCharAt
oRpl = new stzStringReplacer("hello")
? "CharReplacedAt(1,'H'): " + oRpl.CharReplacedAt(1, "H")
#--> Hello

# Replace2 (two pairs at once)
oRpl = new stzStringReplacer("hello world")
oRpl.Replace2("hello", "HI", "world", "THERE")
? "Replace2: " + oRpl.Content()
#--> HI THERE

? ""
? "=== Getter Tests (new) ==="

# CharNgrams
oGet = new stzStringGetter("abc")
aNg = oGet.CharNgrams(2)
? "CharNgrams('abc',2) count: " + len(aNg)

? ""
? "=== Numbers Tests (new) ==="

# ScanInteger
oNum = new stzStringNumbers("42abc")
? "ScanInteger('42abc'): " + oNum.ScanInteger()
#--> 42

oNum = new stzStringNumbers("abc")
? "ScanInteger('abc'): " + oNum.ScanInteger()

? ""
? "=== Checker Tests (batch 3) ==="

# IsWord (engine-backed)
oChk = new stzStringChecker("hello")
? "IsWord('hello'): " + oChk.IsWord()
#--> 1

oChk = new stzStringChecker("hello world")
? "IsWord('hello world'): " + oChk.IsWord()
#--> 0

oChk = new stzStringChecker("")
? "IsWord(''): " + oChk.IsWord()
#--> 0

# IsCharsSortedAscending
oChk = new stzStringChecker("abcde")
? "IsCharsSortedAsc('abcde'): " + oChk.IsCharsSortedAscending()
#--> 1

oChk = new stzStringChecker("edcba")
? "IsCharsSortedDesc('edcba'): " + oChk.IsCharsSortedDescending()
#--> 1

oChk = new stzStringChecker("hello")
? "IsCharsSortedAsc('hello'): " + oChk.IsCharsSortedAscending()
#--> 0

? ""
? "=== Replacer Tests (batch 3) ==="

# Spacify
oRpl = new stzStringReplacer("hello")
? "Spacified('hello'): " + oRpl.Spacified()
#--> h e l l o

# StripMarks
oRpl = new stzStringReplacer("hello")
? "MarksStripped('hello'): " + oRpl.MarksStripped()
#--> hello (no marks to strip)

? ""
? "=== All batch 2+3 tests completed ==="
