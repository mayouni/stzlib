load "../../stzBase.ring"
load "../_narrated.ring"

# FindSubStringBoundedByCS: only the occurrences that ARE a whole
# bounded content count -- the "word" inside <<noword>> is skipped.
# Archive block #545.

Scenario("Case-insensitive bounded word find")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	Then("only the two real <<word>>s",
		ListEq( o1.FindSubStringBoundedByCS("word", [ "<<", ">>" ], :CaseSensitive = FALSE),
			[ 11, 43 ] ), TRUE)
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
