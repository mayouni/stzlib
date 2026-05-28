load "../stzBase.ring"

_nPassed_ = 0
_nFailed_ = 0
_nTotal_ = 0

? "=== stzString Between Operations Test ==="

# Engine replaces the ENTIRE bounded region (open+content+close) with replacement

# --- ReplaceBetween (ALL occurrences) ---
_oStr_ = new stzString("say [hello] and [world] please")
_oStr_.ReplaceBetween("[", "]", "X")
_nTotal_++
if _oStr_.Content() = "say X and X please"
	? "  PASS: ReplaceBetween all" _nPassed_++
else
	? "  FAIL: ReplaceBetween all got=" + _oStr_.Content() _nFailed_++
ok

# --- ReplaceFirstBetween ---
_oStr2_ = new stzString("say [hello] and [world] please")
_oStr2_.ReplaceFirstBetween("[", "]", "FIRST")
_nTotal_++
if _oStr2_.Content() = "say FIRST and [world] please"
	? "  PASS: ReplaceFirstBetween" _nPassed_++
else
	? "  FAIL: ReplaceFirstBetween got=" + _oStr2_.Content() _nFailed_++
ok

# --- ReplaceLastBetween ---
_oStr3_ = new stzString("say [hello] and [world] please")
_oStr3_.ReplaceLastBetween("[", "]", "LAST")
_nTotal_++
if _oStr3_.Content() = "say [hello] and LAST please"
	? "  PASS: ReplaceLastBetween" _nPassed_++
else
	? "  FAIL: ReplaceLastBetween got=" + _oStr3_.Content() _nFailed_++
ok

# --- ReplaceNthBetween ---
_oStr4_ = new stzString("<a> <b> <c>")
_oStr4_.ReplaceNthBetween(2, "<", ">", "X")
_nTotal_++
if _oStr4_.Content() = "<a> X <c>"
	? "  PASS: ReplaceNthBetween(2)" _nPassed_++
else
	? "  FAIL: ReplaceNthBetween(2) got=" + _oStr4_.Content() _nFailed_++
ok

# --- RemoveBetween (ALL) ---
_oStr5_ = new stzString("say [hello] and [world] please")
_oStr5_.RemoveBetween("[", "]")
_nTotal_++
if _oStr5_.Content() = "say  and  please"
	? "  PASS: RemoveBetween all" _nPassed_++
else
	? "  FAIL: RemoveBetween all got=" + _oStr5_.Content() _nFailed_++
ok

# --- RemoveFirstBetween ---
_oStr6_ = new stzString("say [hello] and [world] please")
_oStr6_.RemoveFirstBetween("[", "]")
_nTotal_++
if _oStr6_.Content() = "say  and [world] please"
	? "  PASS: RemoveFirstBetween" _nPassed_++
else
	? "  FAIL: RemoveFirstBetween got=" + _oStr6_.Content() _nFailed_++
ok

# --- RemoveLastBetween ---
_oStr7_ = new stzString("say [hello] and [world] please")
_oStr7_.RemoveLastBetween("[", "]")
_nTotal_++
if _oStr7_.Content() = "say [hello] and  please"
	? "  PASS: RemoveLastBetween" _nPassed_++
else
	? "  FAIL: RemoveLastBetween got=" + _oStr7_.Content() _nFailed_++
ok

# --- RemoveNthBetween ---
_oStr8_ = new stzString("<a> <b> <c>")
_oStr8_.RemoveNthBetween(2, "<", ">")
_nTotal_++
if _oStr8_.Content() = "<a>  <c>"
	? "  PASS: RemoveNthBetween(2)" _nPassed_++
else
	? "  FAIL: RemoveNthBetween(2) got=" + _oStr8_.Content() _nFailed_++
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
