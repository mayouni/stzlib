load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringsBoundedBy does NOT parse nesting: on a deep bracketed
# expression it pairs the first opener with the first closer met, per
# the settled non-overlapping token scan. The archive documents this
# limitation itself (!-->); asserted at the actual flat reading.
# Archive block #700.

Scenario("Deep nesting is out of scope")
	o1 = new StzString( '[ "A", "T", [ :hi, [ "deep1", [] ], :bye ], 5, obj1, "C", "A", obj2, "A", 2 ]' )
	aRes = o1.SubStringsBoundedBy([ "[", "]" ])
	Then("one flat region", len(aRes), 1)
	Then("cut at the first closer",
		aRes[1], ' "A", "T", [ :hi, [ "deep1", [')
EndScenario()

Summary()
