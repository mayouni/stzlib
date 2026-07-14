# R6 ACCEPTANCE -- refine/: stzPolyCode comes home
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.8): code carries typed
# refinement points; a change is a typed PROPOSAL through the gate,
# cascade previewed, reversibility built in.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cSrc = 'vat_rate = ' + Char(60) + 'R:PARAM name="vat" value="0.20" min="0" max="0.25"' + Char(62) + nl +
       'sort_by  = ' + Char(60) + 'R:ALGO name="sort" value="quick" options="quick|merge|heap"' + Char(62)
o = new stzRefinableCode(cSrc)

? "-- Scene 1: the declared change surface --"
chk("both refinement points parse", o.NumberOfPoints() = 2)
chk("a PARAM point carries its value", o.ValueOf("vat") = "0.20" and o.KindOf("vat") = "param")
chk("an ALGO point carries its value", o.ValueOf("sort") = "quick")

? ""
? "-- Scene 2: cascade -- the pre-commit review artifact --"
aC = o.Cascade("vat")
chk("cascade locates the point's line", aC[:exists] = 1 and aC[:lines][1] = 1)
chk("an unknown point cascades to nothing", o.Cascade("ghost")[:exists] = 0)

? ""
? "-- Scene 3: a typed proposal through the gate --"
r = o.Refine("vat").To("0.22")
chk("a valid PARAM value is admitted", r[:admitted] = 1)
chk("...and takes effect", o.ValueOf("vat") = "0.22")

? ""
? "-- Scene 4: the gate REFUSES; the source is untouched --"
r2 = o.Refine("vat").To("0.99")
chk("out-of-bounds is refused", r2[:admitted] = 0)
chk("...with a constraint reason", len(StzFind("above max", r2[:why])) > 0)
chk("...and the source is UNCHANGED (LAW 3)", o.ValueOf("vat") = "0.22")
r3 = o.Refine("sort").To("bubble")
chk("an out-of-options value is refused",
	r3[:admitted] = 0 and len(StzFind("not in options", r3[:why])) > 0)

? ""
? "-- Scene 5: reversibility is a data-model primitive --"
o.Refine("sort").To("merge")
chk("a valid option is admitted", o.ValueOf("sort") = "merge")
chk("history records the admitted change", len(o.History()) = 2)
o.Revert()
chk("Revert undoes the last change (typed inverse)", o.ValueOf("sort") = "quick")
o.Revert()
chk("Revert unwinds to the original", o.ValueOf("vat") = "0.20")
chk("nothing left to revert", o.CanRevert() = 0)

? ""
? "-- Scene 6: the bundle persists (*.zrfn) --"
cF = o.Save("t_refine_accept")
chk("a .zrfn file is written",
	len(StzFind("R:PARAM", read(cF))) > 0)
remove(cF)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
