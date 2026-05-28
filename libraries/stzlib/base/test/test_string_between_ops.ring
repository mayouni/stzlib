load "../stzBase.ring"

_nPsd_ = 0
_nFld_ = 0
_nTtl_ = 0

? "=== stzString Between Operations Test ==="

# Softanza convention: bounds NOT included by default
# IB variants include bounds in replacement/removal

_oT_ = new stzString("say [hello] and [world] please")
_oT_.ReplaceBetween("[", "]", "X")
_nTtl_++
if _oT_.Content() = "say [X] and [X] please"
	? "  PASS: ReplaceBetween all"
	_nPsd_++
else
	? "  FAIL: ReplaceBetween all got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("say [hello] and [world] please")
_oT_.ReplaceFirstBetween("[", "]", "FIRST")
_nTtl_++
if _oT_.Content() = "say [FIRST] and [world] please"
	? "  PASS: ReplaceFirstBetween"
	_nPsd_++
else
	? "  FAIL: ReplaceFirstBetween got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("say [hello] and [world] please")
_oT_.ReplaceLastBetween("[", "]", "LAST")
_nTtl_++
if _oT_.Content() = "say [hello] and [LAST] please"
	? "  PASS: ReplaceLastBetween"
	_nPsd_++
else
	? "  FAIL: ReplaceLastBetween got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("<a> <b> <c>")
_oT_.ReplaceNthBetween(2, "<", ">", "X")
_nTtl_++
if _oT_.Content() = "<a> <X> <c>"
	? "  PASS: ReplaceNthBetween(2)"
	_nPsd_++
else
	? "  FAIL: ReplaceNthBetween(2) got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("say [hello] and [world] please")
_oT_.RemoveBetween("[", "]")
_nTtl_++
if _oT_.Content() = "say [] and [] please"
	? "  PASS: RemoveBetween all"
	_nPsd_++
else
	? "  FAIL: RemoveBetween all got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("say [hello] and [world] please")
_oT_.RemoveFirstBetween("[", "]")
_nTtl_++
if _oT_.Content() = "say [] and [world] please"
	? "  PASS: RemoveFirstBetween"
	_nPsd_++
else
	? "  FAIL: RemoveFirstBetween got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("say [hello] and [world] please")
_oT_.RemoveLastBetween("[", "]")
_nTtl_++
if _oT_.Content() = "say [hello] and [] please"
	? "  PASS: RemoveLastBetween"
	_nPsd_++
else
	? "  FAIL: RemoveLastBetween got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("<a> <b> <c>")
_oT_.RemoveNthBetween(2, "<", ">")
_nTtl_++
if _oT_.Content() = "<a> <> <c>"
	? "  PASS: RemoveNthBetween(2)"
	_nPsd_++
else
	? "  FAIL: RemoveNthBetween(2) got=" + _oT_.Content()
	_nFld_++
ok

? ""
? "=========================="
? "Total: " + _nTtl_
? "Passed: " + _nPsd_
? "Failed: " + _nFld_
if _nFld_ = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok
