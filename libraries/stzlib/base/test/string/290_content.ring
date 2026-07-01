load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveSections() on OVERLAPPING sections: the original monolith merges
# inclusive/overlapping sections before removing (via stzListOfSections),
# so the same overlapping spans as block #289 remove cleanly. The archive
# block prints the result without a #-->; the merged spans [8,15] + [26,29]
# over "PhpRingRingRingPythonRubyRuby" leave "PhpRingPythonRuby".
# Archive block #290.

Scenario("Removing overlapping sections from a string")
	Given('"PhpRingRingRingPythonRubyRuby"')
	o1 = new stzString("PhpRingRingRingPythonRubyRuby")
	aSections = [ [ 8, 11 ], [ 9, 12 ], [ 10, 13 ], [ 11, 14 ], [ 12, 15 ], [ 26, 29 ] ]
	o1.RemoveSections(aSections)
	Then("the merged spans are removed in one pass",
		o1.Content(), "PhpRingPythonRuby")
EndScenario()

Summary()
