load "../../stzBase.ring"
load "../_narrated.ring"

# IsBoundedBy with char and word bounds. Archive block #805.

Scenario("Braces and a basmala")
	Then("braced", StzStringQ("{nnnnn}").IsBoundedBy([ "{", "}" ]), TRUE)
	o1 = new stzString("بسم الله الرّحمن الرّحيم")
	Then("opens with bism, closes with arrahim",
		o1.IsBoundedBy([ "بسم", "الرّحيم" ]), TRUE)
EndScenario()

Summary()
