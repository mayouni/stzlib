load "../../stzBase.ring"

pr()

? "=== Duplicates Test ==="

_oLst1_ = new stzList(["a", "b", "a", "c", "b"])
if _oLst1_.ContainsDuplicatedItems() ? "  PASS: ContainsDuplicatedItems()" else ? "  FAIL: ContainsDuplicatedItems()" ok
if _oLst1_.HasDuplicates() ? "  PASS: HasDuplicates()" else ? "  FAIL: HasDuplicates()" ok

_aDup_ = _oLst1_.DuplicatedItems()
? "  DuplicatedItems: " + list2str(_aDup_)
if isList(_aDup_) and len(_aDup_) > 0 ? "  PASS: DuplicatedItems() not empty" else ? "  FAIL: DuplicatedItems()" ok

_oLst2_ = new stzList(["a", "b", "c"])
if NOT _oLst2_.ContainsDuplicatedItems() ? "  PASS: No duplicates" else ? "  FAIL: No duplicates" ok

? ""
? "=== DONE ==="

pf()
