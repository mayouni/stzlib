load "../../stzBase.ring"
load "../_narrated.ring"

# IsAtCharsNamedParam recognizes the [:AtChars, cond] named-param shape.
# Archive block #441.

Scenario("Recognizing the :AtChars named param")
	Then("the pair is an :AtChars named param",
		Q([ "atchars", "Q(@char).IsUppercase()" ]).IsAtCharsNamedParam(), TRUE)
EndScenario()

Summary()
