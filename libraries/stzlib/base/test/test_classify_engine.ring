load "../stzBase.ring"

$nPassed = 0
$nFailed = 0

? "=== Classify Engine Delegation Tests ==="
? ""

# Test via stzListClassifier (direct engine)
oClassifier = new stzListClassifier(["a", "b", "a", "c", "b", "a"])
aResult = oClassifier.Classify()
? "Classifier result groups: " + len(aResult)
$Assert("Classify groups count", len(aResult) = 3)

# Check first group is "a" with 3 positions
if len(aResult) >= 1
	$Assert("First group key", aResult[1][1] = "a")
	$Assert("First group positions", len(aResult[1][2]) = 3)
ok

? ""

# Test via stzListSorter (should delegate to classifier)
oSorter = new stzListSorter([10, 20, 10, 30, 20])
aResult2 = oSorter.Classify()
? "Sorter classify groups: " + len(aResult2)
$Assert("Sorter classify groups", len(aResult2) = 3)

? ""

# Test Frequencies
oClassifier2 = new stzListClassifier(["x", "y", "x", "z", "x"])
aFreq = oClassifier2.Frequencies()
? "Frequencies groups: " + len(aFreq)
$Assert("Frequencies groups", len(aFreq) >= 1)

? ""

# --- SUMMARY ---
? "================================"
? "Total: " + ($nPassed + $nFailed)
? "Passed: " + $nPassed
? "Failed: " + $nFailed
if $nFailed = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok


func $Assert(cName, bResult)
	if bResult
		? "  PASS: " + cName
		$nPassed++
	else
		? "  FAIL: " + cName
		$nFailed++
	ok
