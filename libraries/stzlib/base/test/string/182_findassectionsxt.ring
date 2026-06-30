load "../../stzBase.ring"
load "../_narrated.ring"

# FindAsSectionsXT(sub, :Between = [open, close]) gives the [from,to] span of each
# `sub` that sits between the markers. Archive block #182.

Scenario("Finding a starred char between markers, as sections")
	Given('"...<<*>>...<<*>>..."')
	o1 = new stzString("...<<*>>...<<*>>...")
	Then("FindAsSectionsXT('*', :Between=['<<','>>']) gives both spans",
		ListEq( o1.FindAsSectionsXT("*", :Between = [ "<<", ">>" ]), [ [6,6], [14,14] ] ), TRUE)
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
