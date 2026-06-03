# Test engine delegation for stzListOfNumbers
# Run from base/number/test/: D:\Ring126\bin\ring.exe test_engine_listofnumbers.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

? "=== Engine Delegation: stzListOfNumbers.Sum ==="

o1 = new stzListOfNumbers([10, 20, 30, 40])

nResult = o1.Sum()
? "  Sum([10,20,30,40]) = " + nResult
if nResult = 100
	nPass++
else
	nFail++
	? "  FAIL: expected 100, got " + nResult
ok

? ""
? "=== Engine Delegation: stzListOfNumbers.Min ==="

nResult = o1.Min()
? "  Min([10,20,30,40]) = " + nResult
if nResult = 10
	nPass++
else
	nFail++
	? "  FAIL: expected 10, got " + nResult
ok

? ""
? "=== Engine Delegation: stzListOfNumbers.Max ==="

nResult = o1.Max()
? "  Max([10,20,30,40]) = " + nResult
if nResult = 40
	nPass++
else
	nFail++
	? "  FAIL: expected 40, got " + nResult
ok

? ""
? "=== Engine Delegation: stzListOfNumbers.Mean ==="

nResult = o1.Mean()
? "  Mean([10,20,30,40]) = " + nResult
if nResult = 25
	nPass++
else
	nFail++
	? "  FAIL: expected 25, got " + nResult
ok

? ""
? "=== Engine Delegation: stzListOfNumbers.Product ==="

o2 = new stzListOfNumbers([2, 3, 5])
nResult = o2.Product()
? "  Product([2,3,5]) = " + nResult
if nResult = 30
	nPass++
else
	nFail++
	? "  FAIL: expected 30, got " + nResult
ok

? ""
? "=== Engine: Floats ==="

o3 = new stzListOfNumbers([1.5, 2.5, 3.0])
nSum = o3.Sum()
? "  Sum([1.5,2.5,3.0]) = " + nSum
if nSum = 7
	nPass++
else
	nFail++
	? "  FAIL: expected 7, got " + nSum
ok

nMin = o3.Min()
? "  Min([1.5,2.5,3.0]) = " + nMin
if nMin = 1.5
	nPass++
else
	nFail++
	? "  FAIL: expected 1.5, got " + nMin
ok

nMax = o3.Max()
? "  Max([1.5,2.5,3.0]) = " + nMax
if nMax = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3, got " + nMax
ok

? ""
? "=== Engine: Single element ==="

o4 = new stzListOfNumbers([42])
if o4.Sum() = 42 and o4.Min() = 42 and o4.Max() = 42 and o4.Mean() = 42 and o4.Product() = 42
	nPass++
	? "  Single element [42]: all aggregates = 42"
else
	nFail++
	? "  FAIL: single element aggregates"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
