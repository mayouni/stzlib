# Test stzListTrimmer + stzListBounder engine delegation
# Run from base/list/test/: D:\Ring126\bin\ring.exe test_engine_list_trimmer_delegation.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

? "=== Engine Delegation: TrimItem ==="

o1 = new stzListTrimmer(["", "", "hello", "world", "", ""])

o1.TrimItem("")
aResult = o1.Content()
? "  TrimItem(''): " + @@(aResult)
if len(aResult) = 2 and aResult[1] = "hello" and aResult[2] = "world"
	nPass++
else
	nFail++
	? "  FAIL: expected [hello, world]"
ok

? ""
? "=== Engine Delegation: TrimItemFromLeft ==="

o2 = new stzListTrimmer(["x", "x", "a", "b", "x"])

o2.TrimItemFromLeft("x")
aResult2 = o2.Content()
? "  TrimItemFromLeft('x'): " + @@(aResult2)
if len(aResult2) = 3 and aResult2[1] = "a"
	nPass++
else
	nFail++
	? "  FAIL: expected [a, b, x]"
ok

? ""
? "=== Engine Delegation: TrimItemFromRight ==="

o3 = new stzListTrimmer(["a", "b", "x", "x", "x"])

o3.TrimItemFromRight("x")
aResult3 = o3.Content()
? "  TrimItemFromRight('x'): " + @@(aResult3)
if len(aResult3) = 2 and aResult3[1] = "a" and aResult3[2] = "b"
	nPass++
else
	nFail++
	? "  FAIL: expected [a, b]"
ok

? ""
? "=== Engine Delegation: Section ==="

o4 = new stzListBounder(["a", "b", "c", "d", "e"])

aSection = o4.Section(2, 4)
? "  Section(2,4): " + @@(aSection)
if len(aSection) = 3 and aSection[1] = "b" and aSection[3] = "d"
	nPass++
else
	nFail++
	? "  FAIL: expected [b, c, d]"
ok

? ""
? "=== Edge: Section single element ==="

aSection2 = o4.Section(3, 3)
? "  Section(3,3): " + @@(aSection2)
if len(aSection2) = 1 and aSection2[1] = "c"
	nPass++
else
	nFail++
	? "  FAIL: expected [c]"
ok

? ""
? "=== Edge: TrimItem no match ==="

o5 = new stzListTrimmer(["a", "b", "c"])
o5.TrimItem("x")
aResult5 = o5.Content()
? "  TrimItem('x') on [a,b,c]: " + @@(aResult5)
if len(aResult5) = 3
	nPass++
else
	nFail++
	? "  FAIL: expected no change"
ok

? ""
? "=== Mixed types: Section with numbers ==="

o6 = new stzListBounder([10, 20, 30, 40, 50])
aSection3 = o6.Section(1, 3)
? "  Section(1,3) on numbers: " + @@(aSection3)
if len(aSection3) = 3 and aSection3[1] = 10 and aSection3[3] = 30
	nPass++
else
	nFail++
	? "  FAIL: expected [10, 20, 30]"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
# Executed in almost 0 second(s) in Ring 1.27
