# Narrative
# --------
# The "BothAre*" predicate family: type-checking the two members of a pair-sized list.
#
# When a stzList holds exactly two items, Softanza offers a readable shorthand for
# asking whether both members share a type: BothAreNumbers(), BothAreStrings(),
# BothAreLists(), and BothAreObjects(). Each returns TRUE only when both elements
# satisfy the named type. Here a numeric pair [12, 88] is BothAreNumbers, a string
# pair is BothAreStrings, a two-entry pairlist is BothAreLists (each :key = value
# entry is itself a list), and a list of two stzList objects is BothAreObjects.
# These read like English assertions and keep two-element guards concise.
#
# Extracted from stzlisttest.ring, block #201.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("The BothAre* predicate family: type-checking the two members of a pair-sized list.")

	o1 = new stzList([ 12, 88 ])
	Then("botharenumbers example 1", @@( o1.BothAreNumbers() ), @@( TRUE ))

	o1 = new stzList([ "hi", "ring" ])
	Then("botharenumbers example 2", @@( o1.BothAreStrings() ), @@( TRUE ))

	o1 = new stzList([ :name = "Dan", :job = "Programmer" ])
	Then("botharenumbers example 3", @@( o1.BothAreLists() ), @@( TRUE ))

	o1 = new stzList([ o1, o1 ])
	Then("botharenumbers example 4", @@( o1.BothAreObjects() ), @@( TRUE ))
EndScenario()

Summary()
