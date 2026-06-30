load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT([], :BoundedBy = '/', :With = new) replaces the content between the
# bounds; the :BoundedByIB variant replaces the whole region including the
# bounds. Single-string bounds widen to ['/','/']. Archive block #199.

Scenario("Replacing bounded content via ReplaceXT, single / bound")
	Given('"bla bla /.../ and bla!"')
	o1 = new stzString("bla bla /.../ and bla!")
	o1.ReplaceXT( [], :BoundedBy = '/', :With = "bla" )
	Then(":BoundedBy keeps the bounds", o1.Content(), "bla bla /bla/ and bla!")

	o2 = new stzString("bla bla /.../ and bla!")
	o2.ReplaceXT( [], :BoundedByIB = '/', :With = "bla" )
	Then(":BoundedByIB replaces the whole region", o2.Content(), "bla bla bla and bla!")
EndScenario()

Summary()
