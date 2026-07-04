load "../../stzBase.ring"
load "../_narrated.ring"

# Repeated leading chars of an RTL string -- the spaces are LEADING
# (string order), even if they render on the right visually. (The
# archive called TrimRight expecting them gone -- the RTL mixup;
# TrimLeft is the one that removes them.) Archive block #765.

Scenario("Leading spaces before an Arabic word")
	o1 = new stzString("   سلام")
	Then("there is a repeated leading run",
		o1.HasRepeatedLeadingChars(), TRUE)
	Then("made of spaces", o1.RepeatedLeadingChar(), " ")
	o1.TrimRight()
	Then("TrimRight leaves them (they are leading)",
		o1.Content(), "   سلام")
	o1.TrimLeft()
	Then("TrimLeft removes them", o1.Content(), "سلام")
EndScenario()

Summary()
