load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT(sub, :In = scope, :With = new) -- replace `sub` only within the given
# scope substring, leaving identical chars elsewhere untouched. Archive block #195.

Scenario("Replacing a char only inside a scope substring")
	Given('"*** Ring programmin* language ***" (only the trailing * is the typo)')
	# Plain Replace hits every "*":
	o1 = new stzString("*** Ring programmin* language ***")
	o1.Replace("*", :With = "g")
	Then("plain Replace clobbers all the stars", o1.Content(), "ggg Ring programming language ggg")

	# ReplaceXT(:In=...) fixes only the one inside "programmin*":
	o2 = new stzString("*** Ring programmin* language ***")
	o2.ReplaceXT("*", :In = "programmin*", :With = "g")
	Then("ReplaceXT(:In) fixes only the scoped star", o2.Content(), "*** Ring programming language ***")
EndScenario()

Summary()
