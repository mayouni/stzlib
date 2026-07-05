load "../../stzBase.ring"
load "../_narrated.ring"

# Two-char decimal tail. Archive block #283.

Scenario("Head backward-3, tail two digits")
	o1 = new stzString("9999999999")
	o1.SpacifyXT(
		:Using     = [ " ", :AndThen = ".", :LastNChars = 2 ],
		:Step      = [ 3, 2 ],
		:Direction = [ :Backward, :AndThen = 'forward' ]
	)
	Then("grouped", o1.Content(), "99 999 999.99")
EndScenario()

Summary()
