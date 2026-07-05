load "../../stzBase.ring"
load "../_narrated.ring"

# Head grouped in twos, tail in threes. Archive block #285.

Scenario("Two-then-three grouping")
	o1 = new stzString("99999999999999")
	o1.SpacifyXT(
		:Using     = [ " ", :AndThen = ".", :LastNChars = 6 ],
		:Step      = [ 2, :AndThen = 3],
		:Direction = :Backward
	)
	Then("grouped", o1.Content(), "99 99 99 99.999 999")
EndScenario()

Summary()
