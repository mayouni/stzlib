load "../stzBase.ring"

_nPassed_ = 0
_nFailed_ = 0
_nTotal_ = 0

? "=== stzString Between Delegation Test ==="

# --- Between returns ALL matches ---
_oStr_ = new stzString("say [hello] and [world] please")
_aResult_ = _oStr_.Between("[", "]")
_nTotal_++
if len(_aResult_) = 2 and _aResult_[1] = "hello" and _aResult_[2] = "world"
	? "  PASS: Between returns all matches" _nPassed_++
else
	? "  FAIL: Between got " + len(_aResult_) + " items" _nFailed_++
ok

# --- Between with no matches ---
_oStr2_ = new stzString("no brackets here")
_aResult2_ = _oStr2_.Between("[", "]")
_nTotal_++
if len(_aResult2_) = 0
	? "  PASS: Between no matches = empty list" _nPassed_++
else
	? "  FAIL: Between no matches got " + len(_aResult2_) _nFailed_++
ok

# --- Between with single match ---
_oStr3_ = new stzString("one (item) only")
_aResult3_ = _oStr3_.Between("(", ")")
_nTotal_++
if len(_aResult3_) = 1 and _aResult3_[1] = "item"
	? "  PASS: Between single match" _nPassed_++
else
	? "  FAIL: Between single match" _nFailed_++
ok

# --- FirstBetween returns only first ---
_oStr4_ = new stzString("say [hello] and [world] please")
_cFirst_ = _oStr4_.FirstBetween("[", "]")
_nTotal_++
if _cFirst_ = "hello"
	? "  PASS: FirstBetween=hello" _nPassed_++
else
	? "  FAIL: FirstBetween=" + _cFirst_ _nFailed_++
ok

# --- FirstBetween with no match ---
_oStr5_ = new stzString("nothing here")
_cFirst2_ = _oStr5_.FirstBetween("[", "]")
_nTotal_++
if _cFirst2_ = ""
	? "  PASS: FirstBetween no match = empty" _nPassed_++
else
	? "  FAIL: FirstBetween no match got=" + _cFirst2_ _nFailed_++
ok

# --- BetweenCS case-insensitive ---
_oStr6_ = new stzString("from START to end and from start to END again")
_aResult6_ = _oStr6_.BetweenCS("start", "end", :CS = 0)
_nTotal_++
if len(_aResult6_) >= 1
	? "  PASS: BetweenCS CI found " + len(_aResult6_) + " matches" _nPassed_++
else
	? "  FAIL: BetweenCS CI found 0 matches" _nFailed_++
ok

# --- Between with 3 matches ---
_oStr7_ = new stzString("<a> <b> <c>")
_aResult7_ = _oStr7_.Between("<", ">")
_nTotal_++
if len(_aResult7_) = 3 and _aResult7_[1] = "a" and _aResult7_[2] = "b" and _aResult7_[3] = "c"
	? "  PASS: Between 3 matches" _nPassed_++
else
	? "  FAIL: Between 3 matches got " + len(_aResult7_) _nFailed_++
ok

# --- BetweenIB (including bounds) ---
_oStr8_ = new stzString("say [hello] world")
_cIB_ = _oStr8_.BetweenIB("[", "]")
_nTotal_++
if _cIB_ = "[hello]"
	? "  PASS: BetweenIB=[hello]" _nPassed_++
else
	? "  FAIL: BetweenIB=" + _cIB_ _nFailed_++
ok

# --- LastBetween ---
_oStr9_ = new stzString("say [hello] and [world] please")
_cLast_ = _oStr9_.LastBetween("[", "]")
_nTotal_++
if _cLast_ = "world"
	? "  PASS: LastBetween=world" _nPassed_++
else
	? "  FAIL: LastBetween=" + _cLast_ _nFailed_++
ok

# --- NthBetween ---
_oStr10_ = new stzString("<a> <b> <c>")
_cNth1_ = _oStr10_.NthBetween(1, "<", ">")
_cNth2_ = _oStr10_.NthBetween(2, "<", ">")
_cNth3_ = _oStr10_.NthBetween(3, "<", ">")
_nTotal_++
if _cNth1_ = "a" and _cNth2_ = "b" and _cNth3_ = "c"
	? "  PASS: NthBetween 1=a, 2=b, 3=c" _nPassed_++
else
	? "  FAIL: NthBetween 1=" + _cNth1_ + " 2=" + _cNth2_ + " 3=" + _cNth3_ _nFailed_++
ok

# --- LastBetween with no match ---
_oStr11_ = new stzString("no brackets")
_cLastNone_ = _oStr11_.LastBetween("[", "]")
_nTotal_++
if _cLastNone_ = ""
	? "  PASS: LastBetween no match = empty" _nPassed_++
else
	? "  FAIL: LastBetween no match got=" + _cLastNone_ _nFailed_++
ok

# --- NthBetween out of range ---
_oStr12_ = new stzString("[only] one")
_cNthOob_ = _oStr12_.NthBetween(5, "[", "]")
_nTotal_++
if _cNthOob_ = ""
	? "  PASS: NthBetween out of range = empty" _nPassed_++
else
	? "  FAIL: NthBetween out of range got=" + _cNthOob_ _nFailed_++
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
