load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAllExcept accepts the [a, :And = b] spelling for the kept list. Archive #82.

Scenario("Replace-all-except with the :And spelling")
	Given('"--Ring--__Softanza__"')
	o1 = new stzString("--Ring--__Softanza__")
	o1.ReplaceAllExcept([ "Ring", :And = "Softanza" ], :With = AHeart())
	Then("each non-kept run becomes a heart", o1.Content(), "♥Ring♥Softanza♥")
EndScenario()

Summary()
