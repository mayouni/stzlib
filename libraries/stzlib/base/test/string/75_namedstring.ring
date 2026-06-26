load "../../stzBase.ring"
load "../_narrated.ring"

# StzNamedString -- a string that carries a name alongside its content. Built via
# the StzNamedStringQ(:name = value) fluent helper. Archive block #75.
#
# NOTE: the archive #--> for StzType() was ":stznumber" (a copy typo) -- the value
# is a STRING, so the type is "stzstring". Name() returns the bare name ("myname",
# without the ":" sigil).

Scenario("A string that knows its own name")
	Given('StzNamedStringQ(:myname = "Mansour")')
	o1 = StzNamedStringQ(:myname = "Mansour")
	Then("Name() is the declared name", o1.Name(), "myname")
	Then("Content() is the value", o1.Content(), "Mansour")
	Then("StzType() is stzstring (not stznumber)", o1.StzType(), "stzstring")
EndScenario()

Summary()
