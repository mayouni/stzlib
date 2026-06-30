load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveAllExcept([...]) keeps only the listed substrings, removing everything
# else. Archive block #78.

Scenario("Removing everything except the listed runs")
	Given('"--Ring--&__Softanza__"')
	o1 = new stzString("--Ring--&__Softanza__")
	o1.RemoveAllExcept([ "Ring", "&", "Softanza" ])
	Then("only the kept runs remain", o1.Content(), "Ring&Softanza")
EndScenario()

Summary()
