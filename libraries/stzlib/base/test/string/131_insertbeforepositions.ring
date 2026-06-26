load "../../stzBase.ring"
load "../_narrated.ring"

# InsertBeforePositions(positions, sub) -- insert `sub` just before each of the
# given character positions (positions refer to the original string). Archive #131.

Scenario("Inserting spaces to separate run-together words")
	Given('"Ringprogramminglanguageispowerful!"')
	o1 = new stzString("Ringprogramminglanguageispowerful!")
	o1.InsertBeforePositions([ 5, 16, 24, 26], " ")
	Then("spaces appear before each word", o1.Content(), "Ring programming language is powerful!")
EndScenario()

Summary()
