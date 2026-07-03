load "../../stzBase.ring"
load "../_narrated.ring"

# Quiet equality: case-blind equality, or a small length drift
# (abs(lenDiff)/lenThis <= QuietEqualityRatio(), 0.09 by default).
# Archive block #685.

Scenario("Quietly equal, up to a point")
	o1 = new stzString("SOFTANZA IS AWSOME!")
	Then("case aside: equal", o1.IsQuietEqualTo("softanza is awsome!"), TRUE)
	Then("one extra char: still quiet",
		o1.IsQuietEqualTo("Softansa is aowsome!"), TRUE)
	Then("two extra chars: too loud",
		o1.IsQuietEqualTo("Softansa iis aowsome!"), FALSE)
EndScenario()

Summary()
