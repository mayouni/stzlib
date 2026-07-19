

load "../../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzString Between Operations Test ==="

# Softanza convention: bounds NOT included by default
# IB variants include bounds in replacement/removal

o = new stzString("say [hello] and [world] please")
o.ReplaceBetween("[", "]", "X")
nTtl++
if o.Content() = "say [X] and [X] please"
	? "  PASS: ReplaceBetween all"
	nPsd++
else
	? "  FAIL: ReplaceBetween all got=" + o.Content()
	nFld++
ok

o = new stzString("say [hello] and [world] please")
o.ReplaceFirstBetween("[", "]", "FIRST")
nTtl++
if o.Content() = "say [FIRST] and [world] please"
	? "  PASS: ReplaceFirstBetween"
	nPsd++
else
	? "  FAIL: ReplaceFirstBetween got=" + o.Content()
	nFld++
ok

o = new stzString("say [hello] and [world] please")
o.ReplaceLastBetween("[", "]", "LAST")
nTtl++
if o.Content() = "say [hello] and [LAST] please"
	? "  PASS: ReplaceLastBetween"
	nPsd++
else
	? "  FAIL: ReplaceLastBetween got=" + o.Content()
	nFld++
ok

o = new stzString("<a> <b> <c>")
o.ReplaceNthBetween(2, "<", ">", "X")
nTtl++
if o.Content() = "<a> <X> <c>"
	? "  PASS: ReplaceNthBetween(2)"
	nPsd++
else
	? "  FAIL: ReplaceNthBetween(2) got=" + o.Content()
	nFld++
ok

o = new stzString("say [hello] and [world] please")
o.RemoveBetween("[", "]")
nTtl++
if o.Content() = "say [] and [] please"
	? "  PASS: RemoveBetween all"
	nPsd++
else
	? "  FAIL: RemoveBetween all got=" + o.Content()
	nFld++
ok

o = new stzString("say [hello] and [world] please")
o.RemoveFirstBetween("[", "]")
nTtl++
if o.Content() = "say [] and [world] please"
	? "  PASS: RemoveFirstBetween"
	nPsd++
else
	? "  FAIL: RemoveFirstBetween got=" + o.Content()
	nFld++
ok

o = new stzString("say [hello] and [world] please")
o.RemoveLastBetween("[", "]")
nTtl++
if o.Content() = "say [hello] and [] please"
	? "  PASS: RemoveLastBetween"
	nPsd++
else
	? "  FAIL: RemoveLastBetween got=" + o.Content()
	nFld++
ok

o = new stzString("<a> <b> <c>")
o.RemoveNthBetween(2, "<", ">")
nTtl++
if o.Content() = "<a> <> <c>"
	? "  PASS: RemoveNthBetween(2)"
	nPsd++
else
	? "  FAIL: RemoveNthBetween(2) got=" + o.Content()
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
