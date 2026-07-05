load "../../stzBase.ring"
load "../_narrated.ring"

# The functional SpacifiedXT: thousands with commas, three-digit
# decimal tail after a dot. Archive block #281.

Scenario("A price, comma-grouped")
	Then("123,456,789.050",
		Q("123456789050").SpacifiedXT(
			:Separator = [ ",", "." , :LastNChars = 3 ],
			:Step      = [ 3, 0 ],
			:Direction = :Backward),
		"123,456,789.050")
EndScenario()

Summary()
