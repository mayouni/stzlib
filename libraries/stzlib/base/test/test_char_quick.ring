load "../stzBase.ring"

? "=== Char Quick Test ==="

_nPassed_ = 0
_nFailed_ = 0

# --- IsChar ---
if StzIsChar("A") ? "  PASS: IsChar A" _nPassed_++ else ? "  FAIL: IsChar A" _nFailed_++ ok
if StzIsChar("z") ? "  PASS: IsChar z" _nPassed_++ else ? "  FAIL: IsChar z" _nFailed_++ ok
if NOT StzIsChar("AB") ? "  PASS: IsChar AB=false" _nPassed_++ else ? "  FAIL: IsChar AB" _nFailed_++ ok
if NOT StzIsChar("") ? "  PASS: IsChar empty=false" _nPassed_++ else ? "  FAIL: IsChar empty" _nFailed_++ ok

# --- IsVowel ---
if @IsVowel("a") ? "  PASS: IsVowel a" _nPassed_++ else ? "  FAIL: IsVowel a" _nFailed_++ ok
if NOT @IsVowel("b") ? "  PASS: IsVowel b=false" _nPassed_++ else ? "  FAIL: IsVowel b" _nFailed_++ ok

# --- Unicode ---
_nU_ = StzCharToUnicode("A")
if _nU_ = 65 ? "  PASS: Unicode A=65" _nPassed_++ else ? "  FAIL: Unicode A=" + _nU_ _nFailed_++ ok

_cC_ = StzChar(65)
if _cC_ = "A" ? "  PASS: StzChar 65=A" _nPassed_++ else ? "  FAIL: StzChar 65" _nFailed_++ ok

# --- CharName (engine-backed) ---
_cName_ = StzCharNameByUnicode(65)
if _cName_ = "LATIN CAPITAL LETTER A" ? "  PASS: CharName A" _nPassed_++ else ? "  FAIL: CharName A: " + _cName_ _nFailed_++ ok

# --- IsCharName ---
_oChk_ = new stzString("LATIN SMALL LETTER A")
if _oChk_.IsCharName() ? "  PASS: IsCharName" _nPassed_++ else ? "  FAIL: IsCharName" _nFailed_++ ok

? ""
? "=========================="
? "Total: " + (_nPassed_ + _nFailed_)
? "Passed: " + _nPassed_
? "Failed: " + _nFailed_
if _nFailed_ = 0
	? "ALL TESTS PASSED!"
ok
