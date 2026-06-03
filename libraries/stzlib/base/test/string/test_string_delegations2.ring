load "../../stzBase.ring"

_nPassed_ = 0
_nFailed_ = 0
_nTotal_ = 0

? "=== stzString Extended Delegations Test ==="

# --- ContainsThese ---
_oStr_ = new stzString("Hello beautiful World")
_nTotal_++
if _oStr_.ContainsThese(["Hello", "World"]) = 1
	? "  PASS: ContainsThese found both" _nPassed_++
else
	? "  FAIL: ContainsThese" _nFailed_++
ok

_nTotal_++
if _oStr_.ContainsThese(["Hello", "missing"]) = 0
	? "  PASS: ContainsThese rejects missing" _nPassed_++
else
	? "  FAIL: ContainsThese should be false" _nFailed_++
ok

# --- FindMany ---
_oStr2_ = new stzString("abc def abc ghi def")
_aMany_ = _oStr2_.FindMany(["abc", "def"])
_nTotal_++
if len(_aMany_) = 2
	? "  PASS: FindMany found 2 substrings" _nPassed_++
else
	? "  FAIL: FindMany got " + len(_aMany_) _nFailed_++
ok

# --- FindAsSections ---
_oStr3_ = new stzString("hello world hello")
_aSections_ = _oStr3_.FindAsSections("hello")
_nTotal_++
if len(_aSections_) = 2
	? "  PASS: FindAsSections found 2 sections" _nPassed_++
else
	? "  FAIL: FindAsSections got " + len(_aSections_) _nFailed_++
ok

# --- ReplaceMany ---
_oStr4_ = new stzString("red blue green")
_oStr4_.ReplaceMany(["red", "blue", "green"], "color")
_nTotal_++
if _oStr4_.Content() = "color color color"
	? "  PASS: ReplaceMany" _nPassed_++
else
	? "  FAIL: ReplaceMany got=" + _oStr4_.Content() _nFailed_++
ok

# --- RemoveMany ---
_oStr5_ = new stzString("hello world hello")
_oStr5_.RemoveMany(["hello", "world"])
_cRmResult_ = _oStr5_.Content()
_nTotal_++
# After removing "hello" and "world", only spaces remain
_oTrimmed_ = new stzString(_cRmResult_)
if StzLen(_oTrimmed_.Trimmed()) = 0
	? "  PASS: RemoveMany removed all substrings" _nPassed_++
else
	? "  FAIL: RemoveMany got=" + _cRmResult_ _nFailed_++
ok

# --- RemoveNth ---
_oStr6_ = new stzString("ab cd ab ef ab")
_oStr6_.RemoveNth(2, "ab")
_nTotal_++
if _oStr6_.Contains("ab") = 1
	? "  PASS: RemoveNth removed 2nd occurrence" _nPassed_++
else
	? "  FAIL: RemoveNth" _nFailed_++
ok

# --- Surround ---
_oStr7_ = new stzString("hello")
_oStr7_.Surround("[", "]")
_nTotal_++
if _oStr7_.Content() = "[hello]"
	? "  PASS: Surround=[hello]" _nPassed_++
else
	? "  FAIL: Surround=" + _oStr7_.Content() _nFailed_++
ok

# --- Surrounded ---
_oStr8_ = new stzString("world")
_cSrd_ = _oStr8_.Surrounded("(", ")")
_nTotal_++
if _cSrd_ = "(world)"
	? "  PASS: Surrounded=(world)" _nPassed_++
else
	? "  FAIL: Surrounded=" + _cSrd_ _nFailed_++
ok

# --- Surround does not change original for Surrounded ---
_nTotal_++
if _oStr8_.Content() = "world"
	? "  PASS: Surrounded preserves original" _nPassed_++
else
	? "  FAIL: Surrounded changed original to=" + _oStr8_.Content() _nFailed_++
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
