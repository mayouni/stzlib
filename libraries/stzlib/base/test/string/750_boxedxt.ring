load "../../stzBase.ring"
load "../_narrated.ring"

# BoxedXT with no options: a plain rectangular box. Archive block #750.

Scenario("The default box")
	cExp = "┌──────┐" + NL +
	       "│ RING │" + NL +
	       "└──────┘"
	Then("RING boxed", StzStringQ("RING").BoxedXT([ ]), cExp)
EndScenario()

Summary()
