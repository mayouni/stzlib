load "../../stzBase.ring"

pr()

? "=== stzList Method Audit ==="
? ""

_nPassed_ = 0
_nFailed_ = 0

# --- Core ---
? "--- Core Methods ---"
o = new stzList([1, 2, 3, 4, 5])
if isList(o.Content()) and len(o.Content()) = 5 ? "  PASS: Content()" _nPassed_++ else ? "  FAIL: Content()" _nFailed_++ ok
if o.NumberOfItems() = 5 ? "  PASS: NumberOfItems()" _nPassed_++ else ? "  FAIL: NumberOfItems()" _nFailed_++ ok
if o.NthItem(1) = 1 ? "  PASS: NthItem(1)" _nPassed_++ else ? "  FAIL: NthItem(1)" _nFailed_++ ok
if o.NthItem(5) = 5 ? "  PASS: NthItem(5)" _nPassed_++ else ? "  FAIL: NthItem(5)" _nFailed_++ ok
if o.IsEmpty() = false ? "  PASS: IsEmpty() false" _nPassed_++ else ? "  FAIL: IsEmpty()" _nFailed_++ ok
? ""

# --- Add / Remove ---
? "--- Add / Remove ---"
o2 = new stzList([1, 2, 3])
o2.Add(4)
if o2.NumberOfItems() = 4 ? "  PASS: Add()" _nPassed_++ else ? "  FAIL: Add()" _nFailed_++ ok
if o2.NthItem(4) = 4 ? "  PASS: Add() value" _nPassed_++ else ? "  FAIL: Add() value" _nFailed_++ ok
? ""

# --- Find ---
? "--- Find Methods ---"
o3 = new stzList([10, 20, 30, 20, 40])
aF = o3.Find(20)
if isList(aF) and len(aF) = 2 ? "  PASS: Find() count" _nPassed_++ else ? "  FAIL: Find(): " + len(aF) _nFailed_++ ok
if aF[1] = 2 and aF[2] = 4 ? "  PASS: Find() positions" _nPassed_++ else ? "  FAIL: Find() positions" _nFailed_++ ok
? ""

# --- Contains ---
? "--- Contains ---"
o4 = new stzList([1, 2, 3])
if o4.Contains(2) ? "  PASS: Contains() true" _nPassed_++ else ? "  FAIL: Contains() true" _nFailed_++ ok
if NOT o4.Contains(99) ? "  PASS: Contains() false" _nPassed_++ else ? "  FAIL: Contains() false" _nFailed_++ ok
? ""

# --- Type Checking ---
? "--- Type Checking ---"
o5 = new stzList([1, 2, 3])
if o5.IsListOfNumbers() ? "  PASS: IsListOfNumbers()" _nPassed_++ else ? "  FAIL: IsListOfNumbers()" _nFailed_++ ok

o6 = new stzList(["a", "b", "c"])
if o6.IsListOfStrings() ? "  PASS: IsListOfStrings()" _nPassed_++ else ? "  FAIL: IsListOfStrings()" _nFailed_++ ok
? ""

# --- Min / Max ---
? "--- Min / Max ---"
o7 = new stzList([3, 1, 4, 1, 5, 9])
if o7.Min() = 1 ? "  PASS: Min()" _nPassed_++ else ? "  FAIL: Min(): " + o7.Min() _nFailed_++ ok
if o7.Max() = 9 ? "  PASS: Max()" _nPassed_++ else ? "  FAIL: Max(): " + o7.Max() _nFailed_++ ok
? ""

# --- Reversed ---
? "--- Reversed ---"
o8 = new stzList([1, 2, 3])
aRev = o8.Reversed()
if isList(aRev) and len(aRev) = 3 ? "  PASS: Reversed() count" _nPassed_++ else ? "  FAIL: Reversed()" _nFailed_++ ok
if aRev[1] = 3 and aRev[3] = 1 ? "  PASS: Reversed() values" _nPassed_++ else ? "  FAIL: Reversed() values" _nFailed_++ ok
? ""

# --- Sorted ---
? "--- Sorted ---"
o9 = new stzList([3, 1, 4, 1, 5])
aSorted = o9.Sorted()
if isList(aSorted) and len(aSorted) = 5 ? "  PASS: Sorted() count" _nPassed_++ else ? "  FAIL: Sorted()" _nFailed_++ ok
if aSorted[1] = 1 and aSorted[5] = 5 ? "  PASS: Sorted() values" _nPassed_++ else ? "  FAIL: Sorted() values" _nFailed_++ ok
? ""

# --- Unique ---
? "--- Unique ---"
o10 = new stzList([1, 2, 2, 3, 3, 3])
aUniq = o10.Unique()
if isList(aUniq) and len(aUniq) = 3 ? "  PASS: Unique() count" _nPassed_++ else ? "  FAIL: Unique(): " + len(aUniq) _nFailed_++ ok
? ""

# --- NumberOfOccurrence ---
? "--- NumberOfOccurrence ---"
o11 = new stzList([1, 2, 2, 3, 2])
_nCnt_ = o11.NumberOfOccurrence(2)
if _nCnt_ = 3 ? "  PASS: NumberOfOccurrence()" _nPassed_++ else ? "  FAIL: NumberOfOccurrence(): " + _nCnt_ _nFailed_++ ok
? ""

# ==================
? "=========================="
? "Total: " + (_nPassed_ + _nFailed_)
? "Passed: " + _nPassed_
? "Failed: " + _nFailed_
if _nFailed_ = 0
	? "ALL TESTS PASSED!"
ok

pf()
