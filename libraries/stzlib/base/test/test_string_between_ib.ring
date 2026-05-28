load "../stzBase.ring"

_nPsd_ = 0
_nFld_ = 0
_nTtl_ = 0

? "=== stzString Between IB Operations Test ==="

# IB variants: bounds ARE included in replacement/removal

_oT_ = new stzString("say [hello] and [world] please")
_oT_.ReplaceBetweenIB("[", "]", "X")
_nTtl_++
if _oT_.Content() = "say X and X please"
	? "  PASS: ReplaceBetweenIB all"
	_nPsd_++
else
	? "  FAIL: ReplaceBetweenIB all got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("say [hello] and [world] please")
_oT_.ReplaceFirstBetweenIB("[", "]", "FIRST")
_nTtl_++
if _oT_.Content() = "say FIRST and [world] please"
	? "  PASS: ReplaceFirstBetweenIB"
	_nPsd_++
else
	? "  FAIL: ReplaceFirstBetweenIB got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("say [hello] and [world] please")
_oT_.RemoveBetweenIB("[", "]")
_nTtl_++
if _oT_.Content() = "say  and  please"
	? "  PASS: RemoveBetweenIB all"
	_nPsd_++
else
	? "  FAIL: RemoveBetweenIB all got=" + _oT_.Content()
	_nFld_++
ok

_oT_ = new stzString("say [hello] and [world] please")
_oT_.RemoveFirstBetweenIB("[", "]")
_nTtl_++
if _oT_.Content() = "say  and [world] please"
	? "  PASS: RemoveFirstBetweenIB"
	_nPsd_++
else
	? "  FAIL: RemoveFirstBetweenIB got=" + _oT_.Content()
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
