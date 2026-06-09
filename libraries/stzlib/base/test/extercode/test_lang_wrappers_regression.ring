# Smoke regression for the language-specific wrappers around
# stzExterCode: stzPythonCode, stzRCode, stzJuliaCode, stzPrologCode,
# stzDotCode (Graphviz). Verifies construction + SetCode without
# actually invoking external interpreters.
#
# Run from base/extercode/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== language-wrapper smoke regression ==="

# ------------------------------------------------------------
# stzPythonCode
# ------------------------------------------------------------
? ""
? "--- stzPythonCode ---"

oP = new stzPythonCode
oP.SetCode("x = 1")
chk("stzPythonCode constructs",      isObject(oP))
chk("Code() returns",                isString(oP.Code()))

# @() operator alias for SetCode
oP.@("y = 2")
chk("@() alias works",               isString(oP.Code()))

# XPy() and py() func aliases
oPy2 = XPy()
chk("XPy() helper",                  isObject(oPy2))

oPy3 = py()
chk("py() helper",                   isObject(oPy3))

# ------------------------------------------------------------
# stzRCode
# ------------------------------------------------------------
? ""
? "--- stzRCode ---"

oR1 = new stzRCode
oR1.SetCode("x <- 1")
chk("stzRCode constructs",           isObject(oR1))

# ------------------------------------------------------------
# stzJuliaCode
# ------------------------------------------------------------
? ""
? "--- stzJuliaCode ---"

oJ = new stzJuliaCode
oJ.SetCode("x = 1")
chk("stzJuliaCode constructs",       isObject(oJ))

# ------------------------------------------------------------
# stzPrologCode
# ------------------------------------------------------------
? ""
? "--- stzPrologCode ---"

oPl = new stzPrologCode
oPl.SetCode("main :- write(hello).")
chk("stzPrologCode constructs",      isObject(oPl))

# ------------------------------------------------------------
# stzDotCode (Graphviz)
# ------------------------------------------------------------
? ""
? "--- stzDotCode ---"

oD = new stzDotCode
oD.SetCode("digraph G { A -> B }")
chk("stzDotCode constructs",         isObject(oD))

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL language-wrapper CHECKS PASSED!"
else
	? "SOME language-wrapper CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
