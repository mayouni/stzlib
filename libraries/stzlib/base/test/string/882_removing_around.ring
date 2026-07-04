load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT :AroundEach removes the substring on BOTH sides of each
# anchor. Archive block #882.

Scenario("Dashes hugging three hearts")
	o1 = new stzString("_-♥-_-♥-_-♥-_")
	o1.RemoveXT("-", :AroundEach = "♥")
	Then("hugs released", o1.Content(), "_♥_♥_♥_")
EndScenario()

Summary()
