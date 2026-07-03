load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringBoundsXT(:Of = sub, :UpToNChars = cap): the flat list of the
# per-occurrence bound runs, capped (a number caps both sides, a [l, r]
# pair per side) with the empty sides dropped -- so the lone "(" of
# "(many" shows up between the angle pairs. Archive block #533.

Scenario("Capped bound runs around many")
	o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")
	Then("capped at 1",
		ListEq( o1.SubStringBoundsXT( :Of = "many", :UpToNChars = 1 ),
			[ "<", ">", "(", "<", ">", "<", ">" ] ), TRUE)
	Then("the [1,1] pair is the same",
		ListEq( o1.SubStringBoundsXT( :Of = "many", :UpToNChars = [1, 1] ),
			[ "<", ">", "(", "<", ">", "<", ">" ] ), TRUE)
	Then("asymmetric [1,2]",
		ListEq( o1.SubStringBoundsXT( :Of = "many", :UpToNChars = [ 1, 2 ] ),
			[ "<", ">>", "(", "<", ">>", "<", ">>" ] ), TRUE)
	Then("[2,2] takes both openers",
		ListEq( o1.SubStringBoundsXT(:Of = "many", :UpToNChars = [ 2, 2 ] ),
			[ "<<", ">>", "(", "<<", ">>", "<<", ">>" ] ), TRUE)
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
