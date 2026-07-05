load "../../stzBase.ring"
load "../_narrated.ring"

# ... and a plain string holds neither a number nor a list.
# Archive block #993.

Scenario("Nothing hidden in normal text")
	Then("stzstring", QQ("normal text").StzType(), "stzstring")
	o1 = new stzString("normal text")
	Then("no number inside", o1.IsNumberInString(), FALSE)
	Then("no list inside", o1.IsListInString(), FALSE)
EndScenario()

Summary()
