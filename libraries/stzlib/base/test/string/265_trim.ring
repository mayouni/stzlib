load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveWF drops the items a predicate accepts. Trimmed, split into
# lines, then the all-number lines removed via a func predicate (the
# WF form -- the textual W can't call IsMadeOfNumbers).
# Extracted from stzStringTest.ring, block #265 (migrated from WXT).

Scenario("Dropping the number lines")
	o1 = new stzString("
ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332
")
	Then("only the letter lines remain",
		ListEq( o1.TrimQ().LinesQ().RemoveWFQ(
				func it { return StzStringQ(it).IsMadeOfNumbers() }
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
