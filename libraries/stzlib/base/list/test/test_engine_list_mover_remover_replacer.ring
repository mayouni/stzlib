# Test engine delegation for stzListMover, stzListRemover, stzListReplacer
# Run from base/list/test/: D:\Ring126\bin\ring.exe test_engine_list_mover_remover_replacer.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

? "=== Engine Delegation: Swap ==="

o1 = new stzListMover(["a", "b", "c", "d"])
o1.Swap(1, 4)
aResult = o1.Content()
? "  Swap(1,4): " + @@(aResult)
if len(aResult) = 4 and aResult[1] = "d" and aResult[4] = "a"
	nPass++
else
	nFail++
	? "  FAIL: expected [d, b, c, a]"
ok

? ""
? "=== Engine Delegation: Reverse ==="

o2 = new stzListMover(["x", "y", "z"])
o2.Reverse()
aResult2 = o2.Content()
? "  Reverse(): " + @@(aResult2)
if len(aResult2) = 3 and aResult2[1] = "z" and aResult2[3] = "x"
	nPass++
else
	nFail++
	? "  FAIL: expected [z, y, x]"
ok

? ""
? "=== Engine Delegation: Shuffle ==="

o3 = new stzListMover(["a", "b", "c", "d", "e"])
o3.Shuffle()
aResult3 = o3.Content()
? "  Shuffle() length: " + len(aResult3)
if len(aResult3) = 5
	nPass++
else
	nFail++
	? "  FAIL: expected 5 items"
ok

? ""
? "=== Engine Delegation: RemoveItemAtPosition ==="

o4 = new stzListRemover(["a", "b", "c", "d", "e"])
o4.RemoveItemAtPosition(3)
aResult4 = o4.Content()
? "  RemoveItemAtPosition(3): " + @@(aResult4)
if len(aResult4) = 4 and aResult4[1] = "a" and aResult4[3] = "d"
	nPass++
else
	nFail++
	? "  FAIL: expected [a, b, d, e]"
ok

? ""
? "=== Engine Delegation: RemoveAll ==="

o5 = new stzListRemover(["x", "a", "x", "b", "x"])
o5.RemoveAll("x")
aResult5 = o5.Content()
? "  RemoveAll('x'): " + @@(aResult5)
if len(aResult5) = 2 and aResult5[1] = "a" and aResult5[2] = "b"
	nPass++
else
	nFail++
	? "  FAIL: expected [a, b]"
ok

? ""
? "=== Engine Delegation: RemoveFirstItem ==="

o6 = new stzListRemover(["first", "second", "third"])
o6.RemoveFirstItem()
aResult6 = o6.Content()
? "  RemoveFirstItem(): " + @@(aResult6)
if len(aResult6) = 2 and aResult6[1] = "second"
	nPass++
else
	nFail++
	? "  FAIL: expected [second, third]"
ok

? ""
? "=== Engine Delegation: RemoveLastItem ==="

o7 = new stzListRemover(["first", "second", "third"])
o7.RemoveLastItem()
aResult7 = o7.Content()
? "  RemoveLastItem(): " + @@(aResult7)
if len(aResult7) = 2 and aResult7[2] = "second"
	nPass++
else
	nFail++
	? "  FAIL: expected [first, second]"
ok

? ""
? "=== Engine Delegation: ReplaceAt ==="

o8 = new stzListReplacer(["a", "b", "c"])
o8.ReplaceAt(2, "B")
aResult8 = o8.Content()
? "  ReplaceAt(2, 'B'): " + @@(aResult8)
if len(aResult8) = 3 and aResult8[2] = "B"
	nPass++
else
	nFail++
	? "  FAIL: expected [a, B, c]"
ok

? ""
? "=== Engine Delegation: SwapItems (Inserter) ==="

o9 = new stzListInserter(["1", "2", "3"])
o9.SwapItems(1, 3)
aResult9 = o9.Content()
? "  SwapItems(1,3): " + @@(aResult9)
if len(aResult9) = 3 and aResult9[1] = "3" and aResult9[3] = "1"
	nPass++
else
	nFail++
	? "  FAIL: expected [3, 2, 1]"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
