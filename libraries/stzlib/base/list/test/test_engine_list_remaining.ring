# Test engine delegation for remaining list submodules
# Run from base/list/test/: D:\Ring126\bin\ring.exe test_engine_list_remaining.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

? "=== Engine Delegation: Performer.Yield ==="

o1 = new stzListPerformer([1, 2, 3, 4, 5])
aResult = o1.Yield('{ @item * 2 }')
? "  Yield('{ @item * 2 }'): " + @@(aResult)
if len(aResult) = 5 and aResult[1] = 2 and aResult[3] = 6 and aResult[5] = 10
	nPass++
else
	nFail++
	? "  FAIL: expected [2, 4, 6, 8, 10]"
ok

? ""
? "=== Engine Delegation: Performer.Perform ==="

o2 = new stzListPerformer([10, 20, 30])
o2.Perform('{ @item + 1 }')
aResult2 = o2.Content()
? "  Perform('{ @item + 1 }'): " + @@(aResult2)
if len(aResult2) = 3 and aResult2[1] = 11 and aResult2[2] = 21 and aResult2[3] = 31
	nPass++
else
	nFail++
	? "  FAIL: expected [11, 21, 31]"
ok

? ""
? "=== Engine Delegation: Getter.Section ==="

o3 = new stzListGetter(["a", "b", "c", "d", "e"])
aResult3 = o3.Section(2, 4)
? "  Section(2,4): " + @@(aResult3)
if len(aResult3) = 3 and aResult3[1] = "b" and aResult3[3] = "d"
	nPass++
else
	nFail++
	? "  FAIL: expected [b, c, d]"
ok

? ""
? "=== Engine Delegation: Getter.NRandomItems ==="

o4 = new stzListGetter([10, 20, 30, 40, 50])
aResult4 = o4.NRandomItems(3)
? "  NRandomItems(3): " + @@(aResult4)
if len(aResult4) = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3 items"
ok

? ""
? "=== Engine Delegation: Stringify.Join ==="

o5 = new stzListStringify(["hello", "world", "zig"])
cResult5 = o5.Join(", ")
? "  Join(', '): " + cResult5
if cResult5 = "hello, world, zig"
	nPass++
else
	nFail++
	? "  FAIL: expected 'hello, world, zig'"
ok

? ""
? "=== Engine Delegation: Stringify.Join numbers ==="

o6 = new stzListStringify([1, 2, 3])
cResult6 = o6.Join("-")
? "  Join('-') numbers: " + cResult6
if cResult6 = "1-2-3"
	nPass++
else
	nFail++
	? "  FAIL: expected '1-2-3'"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
