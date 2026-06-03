load "../../base/stzBase.ring"

$nPassed = 0
$nFailed = 0

? "=== Unicode Normalization Engine Delegation Tests ==="
? ""

# Test NFC normalization (composed form)
# U+00E9 (e with accent, precomposed) vs U+0065 U+0301 (e + combining accent)
oEnc = new stzStringEncoder("cafe" + char(0xCC) + char(0x81))
cNFC = oEnc.NormalizedNFC()
? "  NFC length chars: original vs normalized"
$Assert("NFC returns string", isString(cNFC))
$Assert("NFC non-empty", len(cNFC) > 0)

# Test NFD normalization (decomposed form)
oEnc2 = new stzStringEncoder("caf" + char(0xC3) + char(0xA9))
cNFD = oEnc2.NormalizedNFD()
? "  NFD result available"
$Assert("NFD returns string", isString(cNFD))
$Assert("NFD non-empty", len(cNFD) > 0)

# Test NFKC
oEnc3 = new stzStringEncoder("hello")
cNFKC = oEnc3.NormalizedNFKC()
? "  NFKC of ASCII"
$Assert("NFKC of ASCII unchanged", cNFKC = "hello")

# Test NFKD
cNFKD = oEnc3.NormalizedNFKD()
? "  NFKD of ASCII"
$Assert("NFKD of ASCII unchanged", cNFKD = "hello")

# Test default Normalize (= NFC)
oEnc4 = new stzStringEncoder("test")
cNorm = oEnc4.Normalized()
$Assert("Default normalize = NFC", cNorm = "test")

# Test mutating version
oEnc5 = new stzStringEncoder("world")
oEnc5.Normalize()
$Assert("Mutating normalize works", oEnc5.Content() = "world")

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
