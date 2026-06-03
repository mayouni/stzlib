load "../../base/stzBase.ring"

_nPassed_ = 0
_nFailed_ = 0
_nTotal_ = 0

? "=== stzString Engine Delegation Batch Test ==="

# --- NumberOfOccurrenceCS (fixed CI bug) ---
_oStr_ = new stzString("Hello hello HELLO world")
_nTotal_++
if _oStr_.NumberOfOccurrenceCS("hello", :CS = 0) = 3
	? "  PASS: NumberOfOccurrenceCS CI=3" _nPassed_++
else
	? "  FAIL: NumberOfOccurrenceCS CI=" + _oStr_.NumberOfOccurrenceCS("hello", :CS = 0) _nFailed_++
ok

_nTotal_++
if _oStr_.NumberOfOccurrenceCS("hello", :CS = 1) = 1
	? "  PASS: NumberOfOccurrenceCS CS=1" _nPassed_++
else
	? "  FAIL: NumberOfOccurrenceCS CS=" + _oStr_.NumberOfOccurrenceCS("hello", :CS = 1) _nFailed_++
ok

# --- InsertBefore (engine-backed) ---
_oIns_ = new stzString("Hello World")
_oIns_.InsertBefore(6, " Beautiful")
_nTotal_++
if _oIns_.Content() = "Hello Beautiful World"
	? "  PASS: InsertBefore" _nPassed_++
else
	? "  FAIL: InsertBefore got=" + _oIns_.Content() _nFailed_++
ok

# --- InsertBefore at position 1 ---
_oIns2_ = new stzString("World")
_oIns2_.InsertBefore(1, "Hello ")
_nTotal_++
if _oIns2_.Content() = "Hello World"
	? "  PASS: InsertBefore(1)" _nPassed_++
else
	? "  FAIL: InsertBefore(1) got=" + _oIns2_.Content() _nFailed_++
ok

# --- Lines (engine-backed) ---
_oLines_ = new stzString("line1" + NL + "line2" + NL + "line3")
_aLines_ = _oLines_.Lines()
_nTotal_++
if len(_aLines_) = 3 and _aLines_[1] = "line1" and _aLines_[3] = "line3"
	? "  PASS: Lines" _nPassed_++
else
	? "  FAIL: Lines len=" + len(_aLines_) _nFailed_++
ok

# --- NumberOfLines (engine-backed) ---
_nTotal_++
if _oLines_.NumberOfLines() = 3
	? "  PASS: NumberOfLines=3" _nPassed_++
else
	? "  FAIL: NumberOfLines=" + _oLines_.NumberOfLines() _nFailed_++
ok

# --- UniqueChars (engine-backed) ---
_oUc_ = new stzString("aabbcc")
_aUc_ = _oUc_.UniqueChars()
_nTotal_++
if len(_aUc_) = 3
	? "  PASS: UniqueChars len=3" _nPassed_++
else
	? "  FAIL: UniqueChars len=" + len(_aUc_) _nFailed_++
ok

# --- Repeated (engine-backed) ---
_oRpt_ = new stzString("ab")
_cRpt_ = _oRpt_.Repeated(3)
_nTotal_++
if _cRpt_ = "ababab"
	? "  PASS: Repeated(3)=ababab" _nPassed_++
else
	? "  FAIL: Repeated(3)=" + _cRpt_ _nFailed_++
ok

# --- IsEqualToCS (engine-backed) ---
_oEq_ = new stzString("Hello")
_nTotal_++
if _oEq_.IsEqualToCS("hello", :CS = 0) = 1
	? "  PASS: IsEqualToCS CI" _nPassed_++
else
	? "  FAIL: IsEqualToCS CI" _nFailed_++
ok

_nTotal_++
if _oEq_.IsEqualToCS("hello", :CS = 1) = 0
	? "  PASS: IsEqualToCS CS (diff)" _nPassed_++
else
	? "  FAIL: IsEqualToCS CS (should differ)" _nFailed_++
ok

_nTotal_++
if _oEq_.IsEqualTo("Hello") = 1
	? "  PASS: IsEqualTo exact" _nPassed_++
else
	? "  FAIL: IsEqualTo exact" _nFailed_++
ok

? ""
? "=========================="
? "Total: " + _nTotal_
? "Passed: " + _nPassed_
? "Failed: " + _nFailed_
if _nFailed_ = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok
