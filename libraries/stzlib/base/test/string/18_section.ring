load "../../stzBase.ring"
load "../_narrated.ring"

# Section(a, b) -- the substring spanning positions a..b, INCLUSIVE. The two
# bounds are auto-ordered, so Section(5, 3) gives the same span as Section(3, 5).
# Archive block #18.

Scenario("A string section is bound-order independent")
	Given('"12345678"')
	o1 = new stzString("12345678")
	Then("Section(3, 5) spans positions 3..5", o1.Section(3, 5), "345")
	Then("Section(5, 3) auto-orders to the same span", o1.Section(5, 3), "345")
EndScenario()

Summary()
