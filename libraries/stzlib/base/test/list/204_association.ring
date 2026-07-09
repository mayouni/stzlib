# Narrative
# --------
# Association() zips two parallel lists into a list of [key, value] pairs.
#
# Given a 2-element list whose first member holds the keys and whose second
# member holds the matching values, Association() walks both in lockstep and
# emits one [key, value] couple per index. Here [1,2,3] paired with
# ["One","Two","Three"] yields [ [1,"One"], [2,"Two"], [3,"Three"] ] -- the
# canonical Softanza idiom for turning "columns" of related data into an
# association-style list of pairs ready for hash/pair processing.
#
# Extracted from stzlisttest.ring, block #204.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Association() zips two parallel lists into a list of [key, value] pairs.")

	Then("association example 1", @@( Association([ [ 1, 2, 3 ], [ "One", "Two", "Three" ] ]) ), @@( [ [ 1, "One" ], [ 2, "Two" ], [ 3, "Three" ] ] ))
EndScenario()

Summary()
