load "../../stzBase.ring"
load "../_narrated.ring"

# Section(a, b) on a string -- the a..b span, bound-order independent. Archive #152.

Scenario("A string section is bound-order independent")
	Given('"softanza"')
	o1 = new stzString("softanza")
	Then("Section(4, 6) is 'tan'", o1.Section(4, 6), "tan")
	Then("Section(6, 4) auto-orders to the same", o1.Section(6, 4), "tan")
EndScenario()

Summary()
