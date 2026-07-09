# Narrative
# --------
# The empty-string toolkit: detect, count, locate, replace, and remove the
# "" holes in a list.
#
# ContainsEmptyStrings / CountEmptyStrings / FindEmptyStrings answer the
# questions; ReplaceEmptyStrings(:With = ...) fills the holes in place, and
# RemoveEmptyStrings deletes them outright. A common cleanup step for ragged
# data with blank cells.
#
# Extracted from stzlisttest.ring, block #5.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("The empty-string toolkit: detect, count, locate, replace, and remove the  holes in a list.")

	o1 = new stzList([ "A", '', "B", '', '', "C" ])

	Then("containsemptystrings example 1", @@( o1.ContainsEmptyStrings() ), @@( TRUE ))

	Then("containsemptystrings example 2", @@( o1.CountEmptyStrings() ), @@( 3 ))

	Then("containsemptystrings example 3", @@( o1.FindEmptyStrings() ), @@( [ 2, 4, 5 ] ))

	o1.ReplaceEmptyStrings(:With = "~")
	Then("containsemptystrings example 4", @@( o1.Content() ), @@( [ "A", '~', "B", '~', '~', "C" ] ))

	#--

	o1 = new stzList([ "A", '', "B", '', '', "C" ])
	o1.RemoveEmptyStrings()
	Then("containsemptystrings example 5", @@( o1.Content() ), @@( [ "A", "B", "C" ] ))
EndScenario()

Summary()
