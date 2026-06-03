# Test engine delegation for stzListLeadTrail
# Run from base/list/test/: D:\Ring126\bin\ring.exe test_engine_list_leadtrail.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

? "=== Engine Delegation: RepeatedLeadingItems ==="

o1 = new stzListLeadTrail(["a", "a", "a", "b", "c"])
aResult = o1.RepeatedLeadingItems()
? "  RepeatedLeadingItems: " + @@(aResult)
if len(aResult) = 3 and aResult[1] = "a" and aResult[3] = "a"
	nPass++
else
	nFail++
	? "  FAIL: expected [a, a, a]"
ok

? ""
? "=== Engine Delegation: RepeatedLeadingItems (no repeat) ==="

o2 = new stzListLeadTrail(["a", "b", "c"])
aResult2 = o2.RepeatedLeadingItems()
? "  RepeatedLeadingItems: " + @@(aResult2)
if len(aResult2) = 0
	nPass++
else
	nFail++
	? "  FAIL: expected empty list"
ok

? ""
? "=== Engine Delegation: RepeatedTrailingItems ==="

o3 = new stzListLeadTrail(["a", "b", "c", "c", "c"])
aResult3 = o3.RepeatedTrailingItems()
? "  RepeatedTrailingItems: " + @@(aResult3)
if len(aResult3) = 3 and aResult3[1] = "c" and aResult3[3] = "c"
	nPass++
else
	nFail++
	? "  FAIL: expected [c, c, c]"
ok

? ""
? "=== Engine Delegation: RemoveRepeatedLeadingItems ==="

o4 = new stzListLeadTrail(["x", "x", "x", "a", "b"])
o4.RemoveRepeatedLeadingItems()
aResult4 = o4.Content()
? "  RemoveRepeatedLeadingItems: " + @@(aResult4)
if len(aResult4) = 3 and aResult4[1] = "x" and aResult4[2] = "a"
	nPass++
else
	nFail++
	? "  FAIL: expected [x, a, b]"
ok

? ""
? "=== Engine Delegation: RemoveRepeatedTrailingItems ==="

o5 = new stzListLeadTrail(["a", "b", "y", "y", "y"])
o5.RemoveRepeatedTrailingItems()
aResult5 = o5.Content()
? "  RemoveRepeatedTrailingItems: " + @@(aResult5)
if len(aResult5) = 3 and aResult5[1] = "a" and aResult5[3] = "y"
	nPass++
else
	nFail++
	? "  FAIL: expected [a, b, y]"
ok

? ""
? "=== Engine Delegation: StartsWith ==="

o6 = new stzListLeadTrail(["hello", "world", "test"])
nResult6 = o6.StartsWith("hello")
? "  StartsWith('hello'): " + nResult6
if nResult6 = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1"
ok

? ""
? "=== Engine Delegation: StartsWith (no match) ==="

nResult7 = o6.StartsWith("world")
? "  StartsWith('world'): " + nResult7
if nResult7 = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0"
ok

? ""
? "=== Engine Delegation: EndsWith ==="

nResult8 = o6.EndsWith("test")
? "  EndsWith('test'): " + nResult8
if nResult8 = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1"
ok

? ""
? "=== Engine Delegation: EndsWith (no match) ==="

nResult9 = o6.EndsWith("hello")
? "  EndsWith('hello'): " + nResult9
if nResult9 = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0"
ok

? ""
? "=== Engine Delegation: NumberOfRepeatedLeadingItems ==="

o10 = new stzListLeadTrail(["z", "z", "z", "z", "a"])
nCount = o10.NumberOfRepeatedLeadingItems()
? "  NumberOfRepeatedLeadingItems: " + nCount
if nCount = 4
	nPass++
else
	nFail++
	? "  FAIL: expected 4"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
