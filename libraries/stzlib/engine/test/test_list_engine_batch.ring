load "../../base/stzBase.ring"

_nPassed_ = 0
_nFailed_ = 0
_nTotal_ = 0

? "=== stzList Engine Delegation Batch Test ==="

# --- FindAllOccurrencesCS (engine-backed for strings) ---
_oFnd_ = new stzList(["a", "b", "a", "c", "a"])
_aPos_ = _oFnd_.FindAllOccurrencesCS("a", 1)
_nTotal_++
if len(_aPos_) = 3 and _aPos_[1] = 1 and _aPos_[2] = 3 and _aPos_[3] = 5
	? "  PASS: FindAllOccurrencesCS string" _nPassed_++
else
	? "  FAIL: FindAllOccurrencesCS string got=" + @@(_aPos_) _nFailed_++
ok

# --- FindAllOccurrencesCS case-insensitive ---
_oFnd2_ = new stzList(["Hello", "HELLO", "hello", "world"])
_aPos2_ = _oFnd2_.FindAllOccurrencesCS("hello", 0)
_nTotal_++
if len(_aPos2_) = 3
	? "  PASS: FindAllOccurrencesCS case-insensitive" _nPassed_++
else
	? "  FAIL: FindAllOccurrencesCS CI got=" + @@(_aPos2_) _nFailed_++
ok

# --- FindAllOccurrencesCS number ---
_oFnd3_ = new stzList([1, 2, 3, 2, 4, 2])
_aPos3_ = _oFnd3_.Find(2)
_nTotal_++
if len(_aPos3_) = 3 and _aPos3_[1] = 2 and _aPos3_[2] = 4 and _aPos3_[3] = 6
	? "  PASS: Find(number)" _nPassed_++
else
	? "  FAIL: Find(number) got=" + @@(_aPos3_) _nFailed_++
ok

# --- Sum ---
_oNum_ = new stzList([10, 20, 30])
_nTotal_++
if _oNum_.Sum() = 60
	? "  PASS: Sum=60" _nPassed_++
else
	? "  FAIL: Sum=" + _oNum_.Sum() _nFailed_++
ok

# --- Product ---
_nTotal_++
if _oNum_.Product() = 6000
	? "  PASS: Product=6000" _nPassed_++
else
	? "  FAIL: Product=" + _oNum_.Product() _nFailed_++
ok

# --- Mean ---
_nTotal_++
if _oNum_.Mean() = 20
	? "  PASS: Mean=20" _nPassed_++
else
	? "  FAIL: Mean=" + _oNum_.Mean() _nFailed_++
ok

# --- Median ---
_oMed_ = new stzList([5, 1, 3])
_nTotal_++
_nMed_ = _oMed_.Median()
if _nMed_ = 3
	? "  PASS: Median=3" _nPassed_++
else
	? "  FAIL: Median=" + _nMed_ _nFailed_++
ok

# --- Min / Max ---
_nTotal_++
if _oNum_.Min() = 10
	? "  PASS: Min=10" _nPassed_++
else
	? "  FAIL: Min=" + _oNum_.Min() _nFailed_++
ok

_nTotal_++
if _oNum_.Max() = 30
	? "  PASS: Max=30" _nPassed_++
else
	? "  FAIL: Max=" + _oNum_.Max() _nFailed_++
ok

# --- NthSmallest ---
_oNth_ = new stzList([50, 10, 30, 20, 40])
_nTotal_++
if _oNth_.NthSmallest(2) = 20
	? "  PASS: NthSmallest(2)=20" _nPassed_++
else
	? "  FAIL: NthSmallest(2)=" + _oNth_.NthSmallest(2) _nFailed_++
ok

# --- NthLargest ---
_nTotal_++
if _oNth_.NthLargest(2) = 40
	? "  PASS: NthLargest(2)=40" _nPassed_++
else
	? "  FAIL: NthLargest(2)=" + _oNth_.NthLargest(2) _nFailed_++
ok

# --- Repeated ---
_oRpt_ = new stzList([1, 2])
_aRpt_ = _oRpt_.Repeated(3)
_nTotal_++
if len(_aRpt_) = 6
	? "  PASS: Repeated(3) len=6" _nPassed_++
else
	? "  FAIL: Repeated(3) len=" + len(_aRpt_) _nFailed_++
ok

# --- Join ---
_oJn_ = new stzList(["a", "b", "c"])
_cJn_ = _oJn_.Join("-")
_nTotal_++
if _cJn_ = "a-b-c"
	? "  PASS: Join('-')=a-b-c" _nPassed_++
else
	? "  FAIL: Join('-')=" + _cJn_ _nFailed_++
ok

# --- Count ---
_oCnt_ = new stzList(["x", "y", "x", "z", "x"])
_nTotal_++
if _oCnt_.Count("x") = 3
	? "  PASS: Count('x')=3" _nPassed_++
else
	? "  FAIL: Count('x')=" + _oCnt_.Count("x") _nFailed_++
ok

# --- ContainsCS ---
_nTotal_++
if _oCnt_.ContainsCS("X", 0) = 1
	? "  PASS: ContainsCS('X', CI)" _nPassed_++
else
	? "  FAIL: ContainsCS('X', CI)" _nFailed_++
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
