# Narrative
# --------
#
# Extracted from stzlisttest.ring, block #216.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("repeatedxt")

	Then("repeatedxt example 1", @@( Q(5).RepeatedXT(:InAString, :OfSize = 3) ), @@( "555" ))

	Then("repeatedxt example 2", @@( Q(5).RepeatedXT(:InAList, :OfSize = 3) ), @@( [5, 5, 5] ))

	Then("repeatedxt example 3", @@( Q(5).RepeatedXT( :NTimes = 3, :InAList ) ), @@( [5, 5, 5] ))

	Then("repeatedxt example 4", @@( Q(5).RepeatedXT([ 3, :Times ], :InAList ) ), @@( [5, 5, 5] ))

	Then("repeatedxt example 5", @@( Q(5).RepeatedXT( :NTimes = 3, :InAString ) ), @@( "555" ))

	Then("repeatedxt example 6", @@( Q(5).RepeatedXT([ 3, :Times ], :InString ) ), @@( [5, 5, 5] ))
EndScenario()

Summary()
