# Test: Extended Finder methods (FindAsSections, FindBetween, FindBoundedBy,
#       SubStrings, FindDuplicates, FindW/FindCharsW)
# Run from the test/ directory: ring test_finder_extended.ring

? "Loading stubs + DLL"
load "test_stubs.ring"

load "../stzString.ring"
load "../stzStringFinder.ring"
load "../stzStringReplacer.ring"
load "../stzStringRemover.ring"
load "../stzStringExtractor.ring"
load "../stzStringInserter.ring"

? ""
? "=== Test: FindAsSections ==="
oF = new stzStringFinder("hello ring what a nice ring!")
aSecs = oF.FindAsSections("ring")
? "FindAsSections('ring') count: " + len(aSecs)
if len(aSecs) = 2
    ? "  Section 1: [" + aSecs[1][1] + ", " + aSecs[1][2] + "]"
    ? "  Section 2: [" + aSecs[2][1] + ", " + aSecs[2][2] + "]"
    if aSecs[1][1] = 7 and aSecs[1][2] = 10 and aSecs[2][1] = 24 and aSecs[2][2] = 27
        ? "  PASS"
    else
        ? "  FAIL: wrong positions"
    ok
else
    ? "  FAIL: expected 2 sections"
ok

? ""
? "=== Test: FindBetweenAsSectionCS ==="
oF2 = new stzStringFinder("<<hello world>>")
aS = oF2.FindBetweenAsSectionCS("<<", ">>", 1)
? "FindBetween '<<' and '>>' in '<<hello world>>': [" + aS[1] + ", " + aS[2] + "]"
if aS[1] = 3 and aS[2] = 13
    ? "  PASS"
else
    ? "  FAIL: expected [3, 13]"
ok

? ""
? "=== Test: FindBoundedByAsSectionsCS ==="
oF3 = new stzStringFinder("[one] two [three]")
aSecs3 = oF3.FindBoundedByAsSectionsCS(["[", "]"], 1)
? "FindBoundedBy '[' and ']' count: " + len(aSecs3)
if len(aSecs3) = 2
    ? "  Section 1: [" + aSecs3[1][1] + ", " + aSecs3[1][2] + "]"
    ? "  Section 2: [" + aSecs3[2][1] + ", " + aSecs3[2][2] + "]"
    # [one] is at pos 1-5, content "one" is 2-4
    # [three] is at pos 11-17, content "three" is 12-16
    if aSecs3[1][1] = 2 and aSecs3[1][2] = 4 and aSecs3[2][1] = 12 and aSecs3[2][2] = 16
        ? "  PASS"
    else
        ? "  FAIL: wrong sections"
    ok
else
    ? "  FAIL: expected 2 sections"
ok

? ""
? "=== Test: FindCharsW ==="
oF4 = new stzStringFinder("a1b2c3")
anPos = oF4.FindCharsW('ascii(@char) >= 48 and ascii(@char) <= 57')
? "FindCharsW digits in 'a1b2c3': count = " + len(anPos)
if len(anPos) = 3
    if anPos[1] = 2 and anPos[2] = 4 and anPos[3] = 6
        ? "  PASS"
    else
        ? "  FAIL: wrong positions"
    ok
else
    ? "  FAIL: expected 3 positions"
ok

? ""
? "=== Test: SubStringsCS ==="
oF5 = new stzStringFinder("abc")
acSubs = oF5.SubStringsCS(1)
? "SubStringsCS('abc'): count = " + len(acSubs)
# "abc" has substrings: a, ab, abc, b, bc, c = 6 unique
if len(acSubs) = 6
    ? "  PASS (6 substrings)"
else
    ? "  Got " + len(acSubs) + " substrings"
    for i = 1 to len(acSubs)
        ? "    [" + acSubs[i] + "]"
    next
ok

? ""
? "=== Test: Remover.RemoveW ==="
oRem = new stzStringRemover("a1b2c3")
oRem.RemoveW('ascii(@char) >= 48 and ascii(@char) <= 57')
? "RemoveW digits from 'a1b2c3': [" + oRem.Content() + "]"
if oRem.Content() = "abc"
    ? "  PASS"
else
    ? "  FAIL: expected 'abc'"
ok

? ""
? "=== Test: Remover.RemoveAnyBetween ==="
oRem2 = new stzStringRemover("hello <<world>> there")
oRem2.RemoveAnyBetween("<<", ">>")
? "RemoveAnyBetween '<<' and '>>' : [" + oRem2.Content() + "]"
if oRem2.Content() = "hello <<>> there"
    ? "  PASS"
else
    ? "  FAIL"
ok

? ""
? "=== ALL EXTENDED FINDER TESTS PASSED ==="
