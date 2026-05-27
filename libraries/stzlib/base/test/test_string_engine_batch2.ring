load "../stzBase.ring"

$nPassed = 0
$nFailed = 0

? "=== String Engine Delegation Batch 2 Tests ==="
? ""

# --- COMPARATOR: Jaro / JaroWinkler ---
? "--- Comparator: Jaro / JaroWinkler ---"
oComp = new stzStringComparator("hello")

nJaro = oComp.JaroSimilarityWith("hallo")
? "  Jaro hello/hallo: " + nJaro
$Assert("Jaro returns number", isNumber(nJaro))

nJW = oComp.JaroWinklerSimilarityWith("hallo")
? "  JaroWinkler hello/hallo: " + nJW
$Assert("JaroWinkler returns number", isNumber(nJW))

# Identical strings should have high similarity
oComp2 = new stzStringComparator("test")
nJaroSame = oComp2.JaroSimilarityWith("test")
? "  Jaro test/test: " + nJaroSame

? ""

# --- CHECKER: IsNumeric / IsAlpha ---
? "--- Checker: IsNumeric / IsAlpha ---"
oCheck1 = new stzStringChecker("12345")
$Assert("IsNumericString 12345", oCheck1.IsNumericString() = 1)

oCheck2 = new stzStringChecker("hello")
$Assert("IsNumericString hello", oCheck2.IsNumericString() = 0)
$Assert("IsAlphaString hello", oCheck2.IsAlphaString() = 1)

oCheck3 = new stzStringChecker("abc123")
$Assert("IsAlphaString abc123", oCheck3.IsAlphaString() = 0)

? ""

# --- BOUNDER: BetweenCS engine delegation ---
? "--- Bounder: Between ---"
oB = new stzStringBounder("Hello [World] from [Ring]")
cBetween = oB.Between("[", "]")
? "  Between []: " + cBetween
$Assert("Between brackets", cBetween = "World")

# Test with positions (should still work)
oB2 = new stzStringBounder("ABCDEFGH")
cSec = oB2.Between(2, 5)
? "  Between 2,5: " + cSec
$Assert("Between positions 2-5", cSec = "CD")

? ""

# --- COUNTER: CountOverlapping ---
? "--- Counter: CountOverlapping ---"
oCount = new stzStringCounter("aababaa")
nOver = oCount.CountOverlapping("aba")
? "  CountOverlapping 'aba' in 'aababaa': " + nOver
$Assert("CountOverlapping aba", nOver >= 1)

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
