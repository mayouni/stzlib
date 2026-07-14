# R5 (reactive slice) ACCEPTANCE -- the R54 fix: reactive objects live
# The attribute-redefinition + init-collision bug that retired 8 of 9
# reactiveobject tests is CURED (2026-07-14). This guard exercises the
# exact failing pattern: reactivate -> watch -> set repeatedly.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: reactivate a plain object (init no longer crashes) --"
oPerson = new persr
Rs = new stzReactiveSystem()
oX = Rs.ReactivateObject(oPerson)
chk("ReactivateObject returns a live wrapper", isObject(oX))

? ""
? "-- Scene 2: watch + repeated set (the R54 crash pattern) --"
nFires = 0
oX.Watch(:name, func(oSelf, attr, oldv, newv) { nFires++ })
oX.SetAttribute(:name, "Ali")
oX.SetAttribute(:name, "Mona")
oX.SetAttribute(:age, 30)
oX.SetAttribute(:age, 31)
chk("repeated sets do NOT redefine/crash", oX.GetAttribute(:name) = "Mona")
chk("a second attribute also round-trips", oX.GetAttribute(:age) = 31)
chk("the watcher fired on every name change", nFires = 2)

? ""
? "-- Scene 3: harvested initial values survive --"
oSeed = new persr
oSeed.name = "Zed"
oXs = Rs.ReactivateObject(oSeed)
chk("the wrapped object's initial value is visible",
	oXs.GetAttribute(:name) = "Zed")

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

class persr
	name = ""
	age = 0
