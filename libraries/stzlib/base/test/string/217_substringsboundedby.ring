load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringsBoundedBy('"') with a single repeated quote bound pairs the marks
# OVERLAPPINGLY (the original impl reuses each closer as the next opener), so the
# gap BETWEEN the two quoted segments is also returned. Archive block #217.

Scenario("Extracting segments bounded by a repeated quote mark")
	Given('a line with two double-quoted segments')
	o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')
	Then("all three consecutive gaps are returned, spaces preserved",
		ListEq( o1.SubStringsBoundedBy('"'),
			[ "<    leave spaces    >", " and this code: txt2 = ", "< leave spaces >" ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
