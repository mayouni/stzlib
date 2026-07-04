load "../../stzBase.ring"
load "../_narrated.ring"

# The CS dial on run replacement: case-sensitive, "Oooooh" has NO
# leading run (the lone O breaks at the o); case-insensitive, the
# whole Ooooo is one run. (The archive's first two outputs were
# copy-garble; the CS forms are the point of the block.)
# Archive block #781.

Scenario("Runs that only exist case-blind")
	o1 = new stzString("Oooooh TunisiammMmmM")
	o1.ReplaceLeadingChars(:With = "O")
	Then("case-sensitive: nothing to replace",
		o1.Content(), "Oooooh TunisiammMmmM")
	o1.ReplaceTrailingChars(:With = "!")
	Then("same at the tail", o1.Content(), "Oooooh TunisiammMmmM")
	o2 = new stzString("Oooooh TunisiammMmmM")
	o2.ReplaceLeadingCharsCS(:With = "O", :CaseSensitive = FALSE)
	Then("case-blind: Ooooo collapses to O",
		o2.Content(), "Oh TunisiammMmmM")
	o2.ReplaceTrailingCharsCS(:With = "!", :CaseSensitive = FALSE)
	Then("... and mmMmmM to !", o2.Content(), "Oh Tunisia!")
EndScenario()

Summary()
