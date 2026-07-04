load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSubStringAtPositionsByMany. Archive block #918.

Scenario("Naming the two tilde blocks")
	o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
	o1.ReplaceSubStringAtPositionsByMany([ 27, 34 ], "[~~~]", [ "bbb", "aaa" ])
	Then("each got its own name",
		o1.Content(), "--[...]---[...]---[...]---bbb--aaa--")
EndScenario()

Summary()
