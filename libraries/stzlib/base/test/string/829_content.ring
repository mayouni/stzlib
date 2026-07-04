load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAll on an Arabic sentence. Archive block #829.

Scenario("Foulana becomes Palestine")
	o1 = new stzString("اسمي هو فلانة، قلت لك فلانة! أوَ لم يعجبك أن يكون اسمي فلانة؟")
	o1.ReplaceAll("فلانة", "فلسطين")
	Then("all three replaced",
		o1.Content(),
		"اسمي هو فلسطين، قلت لك فلسطين! أوَ لم يعجبك أن يكون اسمي فلسطين؟")
EndScenario()

Summary()
