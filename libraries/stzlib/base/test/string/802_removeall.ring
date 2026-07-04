load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveAll / RemoveLeftOccurrence / RemoveRightOccurrence.
# Archive block #802.

Scenario("Peeling script tags")
	Then("both tags removed",
		Q("<<script>>func return :done<<script>>").RemoveAllQ("<<script>>").Content(),
		"func return :done")
	Then("only the left one",
		Q("<<script>>func return :done<<script>>").RemoveLeftOccurrenceQ("<<script>>").Content(),
		"func return :done<<script>>")
	o1 = new stzString("<<script>>func return :done<<script>>")
	Then("only the right one",
		o1.RemoveRightOccurrenceQ("<<script>>").Content(),
		"<<script>>func return :done")
	o1.RemoveNFirstChars(10)
	Then("then ten chars off the head", o1.Content(), "func return :done")
EndScenario()

Summary()
