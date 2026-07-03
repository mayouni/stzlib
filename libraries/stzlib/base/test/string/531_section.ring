load "../../stzBase.ring"
load "../_narrated.ring"

# Section basics: single char, a word, and the auto-ordering.
# Archive block #531.

Scenario("Sections in a nice day")
	o1 = new stzString("what a <<nice>>> day!")
	Then("a single char", o1.Section(3, 3), "a")
	Then("the word", o1.Section(10, 13), "nice")
	Then("reversed indexes auto-order", o1.Section(13, 10), "nice")
EndScenario()

Summary()
