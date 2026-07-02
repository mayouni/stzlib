load "../../stzBase.ring"
load "../_narrated.ring"

# Leading-number detection is sign- and decimal-aware: "-23.67 pounds"
# starts with the number "-23.67". Archive block #408.

Scenario("A signed decimal opens the string")
	Given('"-23.67 pounds"')
	o1 = new stzString("-23.67 pounds")
	Then("it starts with a number", o1.StartsWithANumber(), TRUE)
	Then("the starting number", o1.StartingNumber(), "-23.67")
	Then("the explicit check", o1.StartsWithThisNumber("-23.67"), TRUE)
EndScenario()

Summary()
