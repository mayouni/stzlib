load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyXT with named params (:Using, :Step, :Going) -- same as block #275.
# Archive block #276.

Scenario("Grouping from the right, named params (:Going)")
	Given('"99999999999"')
	o1 = new stzString("99999999999")
	o1.SpacifyXT( :Using = " ", :Step = 3, :Going = :Backward )
	Then("the named-param form groups the same", o1.Content(), "99 999 999 999")
EndScenario()

Summary()
