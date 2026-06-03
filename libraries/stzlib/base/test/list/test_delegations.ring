#ERR Error (R24) : Using uninitialized variable: ﻿load
﻿load "../stzBase.ring"

? "=== Replace & Contains Delegation Test ==="

_nPassed_ = 0
_nFailed_ = 0

# --- Replace ---
_oLst1_ = new stzList(["a", "b", "a", "c"])
_oLst1_.Replace("a", "X")
if _oLst1_.Content()[1] = "X" and _oLst1_.Content()[3] = "X"
    ? "  PASS: Replace all" _nPassed_++
else
    ? "  FAIL: Replace all" _nFailed_++
ok

_oLst2_ = new stzList(["a", "b", "a", "c"])
_oLst2_.ReplaceFirst("a", "Y")
if _oLst2_.Content()[1] = "Y" and _oLst2_.Content()[3] = "a"
    ? "  PASS: ReplaceFirst" _nPassed_++
else
    ? "  FAIL: ReplaceFirst" _nFailed_++
ok

_oLst3_ = new stzList(["a", "b", "a", "c"])
_oLst3_.ReplaceLast("a", "Z")
if _oLst3_.Content()[1] = "a" and _oLst3_.Content()[3] = "Z"
    ? "  PASS: ReplaceLast" _nPassed_++
else
    ? "  FAIL: ReplaceLast" _nFailed_++
ok

# --- ReplaceManyByMany ---
_oLst4_ = new stzList(["ring", "qt", "softanza"])
_oLst4_.ReplaceManyByMany(["ring", "softanza"], :By = ["RING", "SOFTANZA"])
if _oLst4_.Content()[1] = "RING" and _oLst4_.Content()[3] = "SOFTANZA"
    ? "  PASS: ReplaceManyByMany" _nPassed_++
else
    ? "  FAIL: ReplaceManyByMany" _nFailed_++
ok

# --- ContainsOneOfThese ---
_oLst5_ = new stzList(["a", "b", "c"])
if _oLst5_.ContainsOneOfThese(["x", "b", "z"])
    ? "  PASS: ContainsOneOfThese true" _nPassed_++
else
    ? "  FAIL: ContainsOneOfThese true" _nFailed_++
ok

if NOT _oLst5_.ContainsOneOfThese(["x", "y", "z"])
    ? "  PASS: ContainsOneOfThese false" _nPassed_++
else
    ? "  FAIL: ContainsOneOfThese false" _nFailed_++
ok

# --- ContainsEither ---
if _oLst5_.ContainsEither(["x", "c"])
    ? "  PASS: ContainsEither" _nPassed_++
else
    ? "  FAIL: ContainsEither" _nFailed_++
ok

# --- ContainsAllOfThese ---
if _oLst5_.ContainsAllOfThese(["a", "c"])
    ? "  PASS: ContainsAllOfThese true" _nPassed_++
else
    ? "  FAIL: ContainsAllOfThese true" _nFailed_++
ok

if NOT _oLst5_.ContainsAllOfThese(["a", "x"])
    ? "  PASS: ContainsAllOfThese false" _nPassed_++
else
    ? "  FAIL: ContainsAllOfThese false" _nFailed_++
ok

? ""
? "=========================="
? "Total: " + (_nPassed_ + _nFailed_)
? "Passed: " + _nPassed_
? "Failed: " + _nFailed_
if _nFailed_ = 0
    ? "ALL TESTS PASSED!"
ok
