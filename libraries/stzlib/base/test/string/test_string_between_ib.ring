

load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzString Between IB Operations Test ==="

# IB variants: bounds ARE included in replacement/removal

o = new stzString("say [hello] and [world] please")
o.ReplaceBetweenIB("[", "]", "X")
nTtl++
if o.Content() = "say X and X please"
	? "  PASS: ReplaceBetweenIB all"
	nPsd++
else
	? "  FAIL: ReplaceBetweenIB all got=" + o.Content()
	nFld++
ok

o = new stzString("say [hello] and [world] please")
o.ReplaceFirstBetweenIB("[", "]", "FIRST")
nTtl++
if o.Content() = "say FIRST and [world] please"
	? "  PASS: ReplaceFirstBetweenIB"
	nPsd++
else
	? "  FAIL: ReplaceFirstBetweenIB got=" + o.Content()
	nFld++
ok

o = new stzString("say [hello] and [world] please")
o.RemoveBetweenIB("[", "]")
nTtl++
if o.Content() = "say  and  please"
	? "  PASS: RemoveBetweenIB all"
	nPsd++
else
	? "  FAIL: RemoveBetweenIB all got=" + o.Content()
	nFld++
ok

o = new stzString("say [hello] and [world] please")
o.RemoveFirstBetweenIB("[", "]")
nTtl++
if o.Content() = "say  and [world] please"
	? "  PASS: RemoveFirstBetweenIB"
	nPsd++
else
	? "  FAIL: RemoveFirstBetweenIB got=" + o.Content()
	nFld++
ok

? ""
? "=========================="
? "Total: " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok

pf()
