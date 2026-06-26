load "../../stzBase.ring"
load "../_narrated.ring"

# FindBoundedByAsSections([open, close]) (a.k.a. FindBoundedByZZ) -- the [from,to]
# spans of the content enclosed by each bound pair. Archive block #162.

Scenario("Finding heart runs enclosed by << >>")
	Given('"--<<♥♥♥>>--<<♥♥♥>>---<<♥♥♥>>"')
	o1 = new stzString("--<<♥♥♥>>--<<♥♥♥>>---<<♥♥♥>>")
	Then("the three enclosed spans are found",
		ListEq( o1.FindBoundedByAsSections([ "<<", ">>" ]), [ [ 5, 7 ], [ 14, 16 ], [ 24, 26 ] ] ), TRUE)
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
