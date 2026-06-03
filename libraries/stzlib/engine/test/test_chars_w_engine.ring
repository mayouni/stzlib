load "../../base/stzBase.ring"

$nPassed = 0
$nFailed = 0

? "=== CharsW Engine Delegation Tests ==="
? ""

# --- FindCharsW: find vowels ---
? "--- FindCharsW ---"
oFind = new stzStringFinder("hello")
aPos = oFind.FindCharsW('@char = "e" or @char = "o"')
? "  FindCharsW vowels: " + len(aPos)
$Assert("FindCharsW finds 2 vowels", len(aPos) = 2)
if len(aPos) >= 2
	$Assert("First vowel at 2", aPos[1] = 2)
	$Assert("Second vowel at 5", aPos[2] = 5)
ok

# --- FindCharsW: by index ---
oFind2 = new stzStringFinder("abcde")
aPos2 = oFind2.FindCharsW("@i > 3")
? "  FindCharsW by index: " + len(aPos2)
$Assert("FindCharsW index > 3", len(aPos2) = 2)

# --- FindCharsW: no match ---
oFind3 = new stzStringFinder("abc")
aPos3 = oFind3.FindCharsW('@char = "z"')
? "  FindCharsW no match: " + len(aPos3)
$Assert("FindCharsW no match", len(aPos3) = 0)

? ""

# --- CountCharsW ---
? "--- CountCharsW ---"
oCount = new stzStringCounter("hello world")
nVowels = oCount.CountCharsW('@char = "e" or @char = "o"')
? "  CountCharsW vowels in hello world: " + nVowels
$Assert("CountCharsW vowels", nVowels = 3)

nCount2 = oCount.CountCharsW('@char = "z"')
$Assert("CountCharsW no match", nCount2 = 0)

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
