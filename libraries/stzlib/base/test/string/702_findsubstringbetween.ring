load "../../stzBase.ring"
load "../_narrated.ring"

# FindSubStringBetween: where a substring sits inside a bounded region.
# Returns the LIST of positions per the settled Find* contract (the
# archive's bare 10 was the legacy single-position shape).
# Archive block #702.

Scenario("KLM between amc and bmi")
	o1 = new stzString("opsus amcKLMbmi findus")
	Then("found at 10",
		ListEq( o1.FindSubStringBetween("KLM", "amc", "bmi"), [ 10 ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
