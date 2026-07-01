load "../../stzBase.ring"
load "../_narrated.ring"

# Capitalcased() = TITLE case: capitalise the first letter of every word (engine
# ToTitle); IsCapitalcase() tests it. Archive block #250.

Scenario("Capital-casing (title case) a string")
	Then("Capitalcased capitalises every word",
		Q("i believe in ring future and engage for it!").Capitalcased(),
		"I Believe In Ring Future And Engage For It!")
	Then("the title-cased string IS capital-case",
		Q("I Believe In Ring Future And Engage For It!").IsCapitalcase(), TRUE)
EndScenario()

Summary()
