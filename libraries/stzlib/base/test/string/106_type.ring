load "../../stzBase.ring"
load "../_narrated.ring"

# ToListOfStzChars() turns a string into a list of stzChar objects. Archive #106.

Scenario("A string as a list of stzChar objects")
	Given('Q("abc").ToListOfStzChars()')
	a = Q("abc").ToListOfStzChars()
	Then("the 2nd item is a stzChar", classname(a[2]), "stzchar")
	Then("its content is 'b'", a[2].Content(), "b")
	Then("its StzType is stzchar", a[2].StzType(), "stzchar")
EndScenario()

Summary()
