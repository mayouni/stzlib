load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAll on a French sentence. Archive block #830.

Scenario("Foulena becomes Tiba")
	o1 = new stzString("Mon prénom c'est Foulèna. J'ai bien dit Foulèna! " +
		"Où bien tu n'aimes pas que ce soit Foulèna?")
	o1.ReplaceAll("Foulèna", "Tiba")
	Then("all three replaced",
		o1.Content(),
		"Mon prénom c'est Tiba. J'ai bien dit Tiba! Où bien tu n'aimes pas que ce soit Tiba?")
EndScenario()

Summary()
