load "../../stzBase.ring"
load "../_narrated.ring"

# Composing Section with NextOccurrence to slice a CSV field.
# Archive block #698.

Scenario("Reading the country out of a record")
	o1 = new stzString("216;TUNISIA;227;NIGER")
	Then("the field after the first ;",
		o1.Section(5, o1.NextOccurrence( :Of = ";", :StartingAt = 5 ) - 1),
		"TUNISIA")
EndScenario()

Summary()
