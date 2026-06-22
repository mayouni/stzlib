load "../../stzBase.ring"

? "=== Checker & Empty Strings Test ==="

_nPassed_ = 0
_nFailed_ = 0

# --- EachItemIsA ---
_oL1_ = new stzList([1, 2, 3])
if _oL1_.EachItemIsA(:Number)
    ? "  PASS: EachItemIsA Number" _nPassed_++
else
    ? "  FAIL: EachItemIsA Number" _nFailed_++
ok

_oL2_ = new stzList(["a", "b", "c"])
if _oL2_.EachItemIsA(:String)
    ? "  PASS: EachItemIsA String" _nPassed_++
else
    ? "  FAIL: EachItemIsA String" _nFailed_++
ok

_oL3_ = new stzList([1, "b", 3])
if NOT _oL3_.EachItemIsA(:Number)
    ? "  PASS: EachItemIsA mixed=false" _nPassed_++
else
    ? "  FAIL: EachItemIsA mixed" _nFailed_++
ok

# --- ContainsEmptyStrings ---
_oL4_ = new stzList(["a", "", "c", ""])
if _oL4_.ContainsEmptyStrings()
    ? "  PASS: ContainsEmptyStrings" _nPassed_++
else
    ? "  FAIL: ContainsEmptyStrings" _nFailed_++
ok

# --- CountEmptyStrings ---
if _oL4_.CountEmptyStrings() = 2
    ? "  PASS: CountEmptyStrings=2" _nPassed_++
else
    ? "  FAIL: CountEmptyStrings" _nFailed_++
ok

# --- FindEmptyStrings ---
_aPos_ = _oL4_.FindEmptyStrings()
if len(_aPos_) = 2 and _aPos_[1] = 2 and _aPos_[2] = 4
    ? "  PASS: FindEmptyStrings" _nPassed_++
else
    ? "  FAIL: FindEmptyStrings" _nFailed_++
ok

# --- ReplaceEmptyStrings ---
_oL5_ = new stzList(["a", "", "c"])
_oL5_.ReplaceEmptyStrings("X")
if _oL5_.Content()[2] = "X"
    ? "  PASS: ReplaceEmptyStrings" _nPassed_++
else
    ? "  FAIL: ReplaceEmptyStrings" _nFailed_++
ok

# --- RemoveEmptyStrings ---
_oL6_ = new stzList(["a", "", "c", ""])
_oL6_.RemoveEmptyStrings()
if _oL6_.NumberOfItems() = 2 and _oL6_.Content()[1] = "a"
    ? "  PASS: RemoveEmptyStrings" _nPassed_++
else
    ? "  FAIL: RemoveEmptyStrings" _nFailed_++
ok

? ""
? "=========================="
? "Total: " + (_nPassed_ + _nFailed_)
? "Passed: " + _nPassed_
? "Failed: " + _nFailed_
if _nFailed_ = 0
    ? "ALL TESTS PASSED!"
ok
