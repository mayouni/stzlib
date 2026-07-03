load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveLast removes the LAST occurrence only. Archive block #582.

Scenario("Dropping the last من")
	o1 = new stzString("من كان في زمنه من أصحابه فهو من أكبر المحظوظين")
	o1.RemoveLast(" من")
	Then("only the third one vanishes",
		o1.Content(), "من كان في زمنه من أصحابه فهو أكبر المحظوظين")
EndScenario()

Summary()
