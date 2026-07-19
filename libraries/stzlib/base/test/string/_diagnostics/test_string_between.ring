

load "../../../stzBase.ring"

pr()

_nPassed_ = 0
_nFailed_ = 0
_nTotal_ = 0

? "=== stzString Between Delegation Test ==="

# --- Between is GREEDY: first opener to LAST closer, ONE string ---
#
# Commit 2887cbd39 (2026-06-30), "Between greedy (per original)", made this
# deliberate to match the monolithic archive, with 6 tests pinning it. This
# file predates that ruling and expected a LIST of every bracketed run.
#
# len() on the result is a CHARACTER count, not an item count -- which is
# why the old failure read "Between got 17 items" for a 17-character string.
_oStr_ = new stzString("say [hello] and [world] please")
_cResult_ = _oStr_.Between("[", "]")
_nTotal_++
if _cResult_ = "hello] and [world"
	? "  PASS: Between is greedy, first opener to last closer" _nPassed_++
else
	? "  FAIL: Between got [" + _cResult_ + "]" _nFailed_++
ok

# --- Between with no matches ---
_oStr2_ = new stzString("no brackets here")
_aResult2_ = _oStr2_.Between("[", "]")
_nTotal_++
# No opener and no closer -> empty, greedy or not.
if len(_aResult2_) = 0
	? "  PASS: Between no matches = empty list" _nPassed_++
else
	? "  FAIL: Between no matches got " + len(_aResult2_) _nFailed_++
ok

# --- Between with single match ---
_oStr3_ = new stzString("one (item) only")
_cResult3_ = _oStr3_.Between("(", ")")
_nTotal_++
# With exactly one pair, greedy and per-match agree.
if _cResult3_ = "item"
	? "  PASS: Between single match" _nPassed_++
else
	? "  FAIL: Between single match got [" + _cResult3_ + "]" _nFailed_++
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
_cResult7_ = _oStr7_.Between("<", ">")
_nTotal_++
# Three pairs, and greedy spans all of them: first < to last >.
if _cResult7_ = "a> <b> <c"
	? "  PASS: Between spans all three pairs greedily" _nPassed_++
else
	? "  FAIL: Between 3 pairs got [" + _cResult7_ + "]" _nFailed_++
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

pf()
