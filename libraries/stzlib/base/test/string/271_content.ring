load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyXT with the named params (:Using, :Step, :Direction) -- the same as the
# positional form in block #270. Archive block #271.

Scenario("Grouping digits from the right, named params")
	Given('"99999999999"')
	o1 = new stzString("99999999999")
	o1.SpacifyXT( :Using = "_", :Step = 3, :Direction = :Backward )
	Then("the named-param form groups the same way", o1.Content(), "99_999_999_999")
EndScenario()

Summary()
