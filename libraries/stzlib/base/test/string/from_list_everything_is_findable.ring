load "../../stzBase.ring"
load "../_narrated.ring"

# NAMED Softanza objects (created as :name = value) are findable
# inside a list; unnamed ones are not. Ring's own find() handles only
# scalars. Extracted from stzlisttest.ring, block #17.

Scenario("Everything is findable")
	o1 = new stzString("hello")
	o2 = new stzString( "hello" )
	o3 = new stzString( :o3 = "hello" )
	Then("all uppercase the same", o1.Uppercased() + o2.Uppercased() + o3.Uppercased(),
		"HELLOHELLOHELLO")
	aMyList = [ "Hi", o1, "how", 1:3, o2, "are", o3, "you?", 1:3, o3, 99 ]
	Then("Ring finds a string", find(aMyList, "how"), 3)
	Then("Ring finds a number", find(aMyList, 99), 11)
	Then("Softanza finds a whole list",
		ListEq( Q(aMyList).Find(1:3), [ 4, 9 ] ), TRUE)
	Then("o3 is a named object", o3.IsNamedObject(), TRUE)
	Then("... so it is findable",
		ListEq( Q(aMyList).Find(o3), [ 7, 10 ] ), TRUE)
	Then("o2 is not named", o2.IsNamedObject(), FALSE)
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
