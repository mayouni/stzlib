load "../../stzBase.ring"
load "../_narrated.ring"

# The :LastNChars can ride inside the :Step spec. Archive block #284.

Scenario("Boundary declared in the step spec")
	o1 = new stzString("999999999999")
	o1.SpacifyXT(
		:Using     = [ " ", "." ],
		:Step      = [ 3, :AndThen = 2, :LastNChars = 5 ],
		:Direction = [ :Backward, :AndThen = 'forward' ]
	)
	Then("head backward-3, tail forward-2", o1.Content(), "9 999 999.99 99 9")
EndScenario()

Summary()
