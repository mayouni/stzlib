# Integration regression for stzExtinCode helpers (iif / Length /
# console).
#
# Run from base/extincode/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzExtinCode integration regression ==="

# ------------------------------------------------------------
# iif: numeric condition
# ------------------------------------------------------------
? ""
? "--- iif numeric ---"

chk("iif(1, 'yes', 'no') = 'yes'",   iif(1, "yes", "no") = "yes")
chk("iif(0, 'yes', 'no') = 'no'",    iif(0, "yes", "no") = "no")

# ------------------------------------------------------------
# iif: string condition (eval-based)
# ------------------------------------------------------------
? ""
? "--- iif string ---"

x = 5
chk("iif('x > 3', ...) = 'big'",      iif("x > 3", "big", "small") = "big")
chk("iif('x < 3', ...) = 'small'",    iif("x < 3", "big", "small") = "small")

# ------------------------------------------------------------
# Aliases iff / @if
# ------------------------------------------------------------
? ""
? "--- iif aliases ---"

chk("iff(1, ...) works",             iff(1, "a", "b") = "a")
chk("@if(0, ...) works",             @if(0, "a", "b") = "b")

# ------------------------------------------------------------
# Length / @Length
# ------------------------------------------------------------
? ""
? "--- Length ---"

chk("Length('hello') = 5",           Length("hello") = 5)
chk("Length([1,2,3]) = 3",           Length([1, 2, 3]) = 3)
chk("@Length wrapper",               @Length("ab") = 2)

# ------------------------------------------------------------
# console.log / WriteLine
# ------------------------------------------------------------
? ""
? "--- console ---"

oCon = new console
# Just verify no crash; output is to stdout
oCon.log("(console.log smoke)")
oCon.WriteLine("(console.WriteLine smoke)")
chk("console smoke completed",       isObject(oCon))

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzExtinCode CHECKS PASSED!"
else
	? "SOME stzExtinCode CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
