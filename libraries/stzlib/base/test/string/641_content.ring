load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifySubStringsUsing inserts the separator around the listed
# substrings. Archive block #641.

Scenario("Wordifying a squashed sentence")
	o1 = new stzString("IloveRingprogramminglanguage!")
	o1.SpacifySubStringsUsing( [ "love", "Ring", "programming" ], " " )
	Then("readable again", o1.Content(), "I love Ring programming language!")
EndScenario()

Summary()
