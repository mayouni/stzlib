load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifySections(listOfRanges) -- apply Spacify (a space between every char) to
# each named section, in place. Archive block #132.
#
# NOTE: the archive #--> showed "Ring programming language is powerful!" -- that
# is block #131's boundary-insert result, copied by mistake. SpacifySections
# actually spacifies the chars WITHIN each section (matching its name), so
# section [5,15] "programming" becomes "p r o g r a m m i n g". Asserted at the
# impl's (name-consistent) behavior.

Scenario("Spacifying the chars inside chosen sections")
	Given('"Ringprogramminglanguageispowerful!"')
	o1 = new stzString("Ringprogramminglanguageispowerful!")
	o1.SpacifySections([ [ 5, 15 ], [ 24, 25 ] ])
	Then("each section's chars are spaced out",
		o1.Content(), "Ringp r o g r a m m i n glanguagei spowerful!")
EndScenario()

Summary()
