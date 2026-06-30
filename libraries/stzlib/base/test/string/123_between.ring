load "../../stzBase.ring"
load "../_narrated.ring"

# Between vs BoundedBy: Between is the GREEDY single span from the first open to
# the last close (a string); BoundedBy returns the LIST of each enclosed region.
# Archive block #123.

Scenario("The text enclosed between distinct bounds")
	Given('"<<***>>**<<***>>"')
	o1 = new stzString("<<***>>**<<***>>")
	Then("Between('<<', :And='>>') is the greedy span (first open to last close)",
		o1.Between("<<", :and = ">>"), "***>>**<<***")
	Then("BoundedBy(['<<','>>']) gives each enclosed region",
		ListEq( o1.BoundedBy([ "<<", ">>" ]), [ "***", "***" ] ), TRUE)
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
