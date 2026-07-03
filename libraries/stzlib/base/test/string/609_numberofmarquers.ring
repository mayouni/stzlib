load "../../stzBase.ring"
load "../_narrated.ring"

# Count, first and last -- the plain forms give the marquer STRING, the
# Find twins its position. Archive block #609.

Scenario("First and last of four")
	o1 = new stzString("My name is #1, my age is #2, and my job is #3. Again: my name is #1!")
	Then("four marquers", o1.NumberOfMarquers(), 4)
	Then("the first", o1.FirstMarquer(), "#1")
	Then("... at 12", o1.FindFirstMarquer(), 12)
	Then("the last", o1.LastMarquer(), "#1")
	Then("... at 66", o1.FindLastMarquer(), 66)
EndScenario()

Summary()
