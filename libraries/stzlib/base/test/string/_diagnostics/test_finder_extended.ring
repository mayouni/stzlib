# Test: Extended Finder methods (FindAsSections, FindBetween, FindBoundedBy,
#       SubStrings, FindDuplicates, FindW/FindCharsW)
# Run from the test/ directory: ring test_finder_extended.ring

? "Loading stubs + DLL"
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
    _nSubsLen_ = len(acSubs)
    for i = 1 to _nSubsLen_
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
# RemoveAnyBetween removes the DELIMITERS TOO. Both sides of the
# implementation say so: the engine's str_remove_between is documented
# "inclusive of delimiters", and the Ring wrapper's own comment reads
# "removes ALL open...close pairs". This test predated that and expected
# "hello <<>> there" -- content gone, bounds kept.
oRem2.RemoveAnyBetween("<<", ">>")
? "RemoveAnyBetween '<<' and '>>' : [" + oRem2.Content() + "]"
if oRem2.Content() = "hello  there"
    ? "  PASS"
else
    ? "  FAIL"
ok

? ""
? "=== ALL EXTENDED FINDER TESTS PASSED ==="
