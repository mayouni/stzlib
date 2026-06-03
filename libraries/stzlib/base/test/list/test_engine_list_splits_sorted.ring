# Test engine delegation for stzListSplits and stzSortedList
# Run from base/list/test/: D:\Ring126\bin\ring.exe test_engine_list_splits_sorted.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

? "=== SplitAtPosition (Ring path) ==="

o1 = new stzListSplits([1, 2, 3, 4, 5, 6])
o1.SplitAtPosition(3)
aResult = o1.Content()
? "  SplitAtPosition(3): " + @@(aResult)
if len(aResult) = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2 groups"
ok

? ""
? "=== Engine Delegation: SortedList init ==="

o4 = new stzSortedList([30, 10, 20])
aResult4 = o4.Content()
? "  SortedList([30,10,20]): " + @@(aResult4)
if len(aResult4) = 3 and aResult4[1] = 10 and aResult4[2] = 20 and aResult4[3] = 30
	nPass++
else
	nFail++
	? "  FAIL: expected [10, 20, 30]"
ok

? ""
? "=== Engine Delegation: SortedList Add ==="

o5 = new stzSortedList([10, 30, 50])
o5.Add(20)
aResult5 = o5.Content()
? "  SortedList.Add(20): " + @@(aResult5)
if len(aResult5) = 4 and aResult5[2] = 20
	nPass++
else
	nFail++
	? "  FAIL: expected [10, 20, 30, 50]"
ok

? ""
? "=== Engine Delegation: SortedList operator+ ==="

o6 = new stzSortedList([5, 15, 25])
o6 + 10
aResult6 = o6.Content()
? "  SortedList + 10: " + @@(aResult6)
if len(aResult6) = 4 and aResult6[2] = 10
	nPass++
else
	nFail++
	? "  FAIL: expected [5, 10, 15, 25]"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
