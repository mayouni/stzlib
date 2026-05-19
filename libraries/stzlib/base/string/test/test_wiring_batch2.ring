load "test_stubs.ring"
load "../stzString.ring"
load "../stzStringChecker.ring"
load "../stzStringComparator.ring"
load "../stzStringReplacer.ring"
load "../stzStringCounter.ring"
load "../stzStringFinder.ring"
load "../stzStringGetter.ring"
load "../stzStringCaseChanger.ring"
load "../stzStringNumbers.ring"

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
for i = 1 to len(aPos)
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
? "=== All batch 2 tests completed ==="
