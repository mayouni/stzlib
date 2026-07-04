load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(sub, :After = anchor): remove sub sitting right after the
# anchor. Archive block #872.

Scenario("A star after programming")
	o1 = new stzString("Ring programming* language.")
	o1.RemoveXT("*", :After = "programming")
	Then("star gone", o1.Content(), "Ring programming language.")
EndScenario()

Summary()
