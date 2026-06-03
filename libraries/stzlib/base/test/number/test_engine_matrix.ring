# Test engine delegation for stzMatrix
# Run from base/number/test/: D:\Ring126\bin\ring.exe test_engine_matrix.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

? "=== Engine Delegation: stzMatrix.Sum ==="

o1 = new stzMatrix([ [1, 2, 3], [4, 5, 6] ])

nResult = o1.Sum()
? "  Sum([[1,2,3],[4,5,6]]) = " + nResult
if nResult = 21
	nPass++
else
	nFail++
	? "  FAIL: expected 21, got " + nResult
ok

? ""
? "=== Engine Delegation: stzMatrix.Min ==="

nResult = o1.Min()
? "  Min = " + nResult
if nResult = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1, got " + nResult
ok

? ""
? "=== Engine Delegation: stzMatrix.Max ==="

nResult = o1.Max()
? "  Max = " + nResult
if nResult = 6
	nPass++
else
	nFail++
	? "  FAIL: expected 6, got " + nResult
ok

? ""
? "=== Engine Delegation: stzMatrix.Mean ==="

nResult = o1.Mean()
? "  Mean = " + nResult
if nResult = 3.50
	nPass++
else
	nFail++
	? "  FAIL: expected 3.5, got " + nResult
ok

? ""
? "=== Engine Delegation: stzMatrix.Determinant ==="

o2 = new stzMatrix([ [1, 2], [3, 4] ])
nDet = o2.Determinant()
? "  Det([[1,2],[3,4]]) = " + nDet
if nDet = -2
	nPass++
else
	nFail++
	? "  FAIL: expected -2, got " + nDet
ok

? ""
? "=== Engine Delegation: stzMatrix.MultiplyByMatrix ==="

o3 = new stzMatrix([ [1, 2], [3, 4] ])
o3.MultiplyByMatrix([ [5, 6], [7, 8] ])
aResult = o3.Content()
? "  [1,2;3,4] * [5,6;7,8] = [" + aResult[1][1] + "," + aResult[1][2] + ";" + aResult[2][1] + "," + aResult[2][2] + "]"
if aResult[1][1] = 19 and aResult[1][2] = 22 and aResult[2][1] = 43 and aResult[2][2] = 50
	nPass++
else
	nFail++
	? "  FAIL: expected [19,22;43,50]"
ok

? ""
? "=== Engine Delegation: stzMatrix.Power ==="

o4 = new stzMatrix([ [2, 3], [4, 5] ])
o4.Power(2)
aResult = o4.Content()
? "  Power(2) of [[2,3],[4,5]] = [" + aResult[1][1] + "," + aResult[1][2] + ";" + aResult[2][1] + "," + aResult[2][2] + "]"
if aResult[1][1] = 4 and aResult[1][2] = 9 and aResult[2][1] = 16 and aResult[2][2] = 25
	nPass++
else
	nFail++
	? "  FAIL: expected [4,9;16,25]"
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
