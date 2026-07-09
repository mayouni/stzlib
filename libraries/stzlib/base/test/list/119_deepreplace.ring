# Narrative
# --------
# DeepReplace() does a recursive replace-by-value across the whole tree.
#
# Unlike a flat Replace() that only touches top-level items, DeepReplace
# descends into every nested sublist and swaps each matching value. Here
# every "me" -- at the top level and inside the two nested lists -- becomes
# "you", while the surrounding structure (nesting depth, order, the
# untouched "other" items) is preserved exactly. Content() then returns the
# rewritten tree. Note the LAST top-level "me" is replaced too, yielding a
# five-element result.
#
# Extracted from stzlisttest.ring, block #119.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("DeepReplace() does a recursive replace-by-value across the whole tree.")

	o1 = new stzList([
		"me",
		"other",
		[ "other", "me", [ "me" ], "other" ],
		"other",
		"me"
	])

	o1.DeepReplace("me", :By = "you")
	Then("deepreplace example 1", @@( o1.Content() ), @@( [ "you", "other", [ "other", "you", [ "you" ], "other" ], "other", "you" ] ))
EndScenario()

Summary()
