load "../../stzBase.ring"
load "../_narrated.ring"

# The same, via the number-in-string predicate. Trimmed lines with
# their all-number members removed (WF func form). Extracted from
# stzStringTest.ring, block #256 (migrated from the retired WXT form).

Scenario("Keeping the non-numeric lines")
	o1 = new stzString("
ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332
")
	Then("the four letter lines",
		ListEq( o1.TrimQ().LinesQ().RemoveWFQ(
				func it { return isNumberInString(it) }
			).Content(),
			[ "ABCDEF", "GHIJKL", "MNOPQU", "RSTUVW" ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
