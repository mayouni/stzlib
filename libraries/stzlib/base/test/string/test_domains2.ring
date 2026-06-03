# Test additional domain classes
# Run from the test/ directory: ring test_domains2.ring

? "Loading stubs + DLL"
#ERR Error (E9) : Can't open file ../stzString.ring

load "test_stubs.ring"

? "Loading classes"
load "../stzString.ring"
load "../stzStringFinder.ring"
load "../stzStringBounder.ring"
load "../stzStringFormatter.ring"
load "../stzStringGetter.ring"
load "../stzStringCounter.ring"
load "../stzStringChecker.ring"
load "../stzStringConcat.ring"

pr()

? ""
? "=== Test: stzStringBounder ==="
oBounder = new stzStringBounder("<<hello>> and <<world>>")
? "  Content: " + oBounder.Content()
? "  Section(1,7): " + oBounder.Section(1, 7)

? ""
? "=== Test: stzStringFormatter ==="
oFmt = new stzStringFormatter("hello world")
? "  Content: " + oFmt.Content()
? "  Uppercased: " + oFmt.Uppercased()

? ""
? "=== Test: stzStringGetter ==="
oGet = new stzStringGetter("Hello Ring")
? "  NthChar(1): " + oGet.NthChar(1)
? "  FirstChar: " + oGet.FirstChar()
? "  LastChar: " + oGet.LastChar()
? "  Section(1,5): " + oGet.Section(1, 5)

? ""
? "=== Test: stzStringCounter ==="
oCnt = new stzStringCounter("abracadabra")
? "  NumberOfChars: " + oCnt.NumberOfChars()

? ""
? "=== Test: stzStringChecker ==="
oChk = new stzStringChecker("abcba")
? "  Content: " + oChk.Content()

? ""
? "=== Test: stzStringConcat ==="
oConcat = new stzStringConcat("Hello")
? "  Content: " + oConcat.Content()

? ""
? "=== ALL ADDITIONAL DOMAIN TESTS PASSED ==="

pf()
