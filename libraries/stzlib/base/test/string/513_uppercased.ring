load "../../stzBase.ring"
load "../_narrated.ring"

# ToListOfStzStrings yields real stzString objects to iterate over.
# Archive block #513.

Scenario("Iterating stzStrings")
	aStzStrList = StzListOfStringsQ([ "one", "two", "three" ]).ToListOfStzStrings()
	acRes = []
	foreach oStr in aStzStrList
		acRes + oStr.Uppercased()
	next
	Then("each uppercases on its own",
		ListEq( acRes, [ "ONE", "TWO", "THREE" ] ), TRUE)
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
