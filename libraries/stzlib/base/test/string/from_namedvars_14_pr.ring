load "../../stzBase.ring"
load "../_narrated.ring"

# A named object carries its name; an unnamed one reports @noname.
# Extracted from stznamedvarstest.ring, block #14.

Scenario("Named and unnamed objects")
	o1 = new stzString(:nation = "Niger")
	Then("it is a stzString", ClassName(o1), "stzstring")
	Then("it is named", IsNamedObject(o1), TRUE)
	Then("its name", ObjectName(o1), "nation")
	o2 = new stzString("Niger")
	Then("this one is not named", IsNamedObject(o2), FALSE)
	Then("... so it reports @noname", ObjectName(o2), "@noname")
EndScenario()

Summary()
