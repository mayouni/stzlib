load "../../stzBase.ring"
load "../_narrated.ring"

# stzsplit(text, NL) splits a multi-line string into its lines (codepoint-faithful;
# trailing spaces are preserved). Archive block #11.

Scenario("Splitting a 3-line string on the newline")
	Given("three lines separated by NL")
	Then("each line becomes an item (whitespace preserved)",
		@@( stzsplit(" line1 line1 line1 " + NL + "line2 line2 line2" + NL + "line3 line3 line3", NL) ),
		@@([ " line1 line1 line1 ", "line2 line2 line2", "line3 line3 line3" ]))
EndScenario()

Summary()
