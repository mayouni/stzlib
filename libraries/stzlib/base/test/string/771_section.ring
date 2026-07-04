load "../../stzBase.ring"
load "../_narrated.ring"

# Section with keyword bounds, and with INVERTED numeric bounds --
# plain Section normalizes them (the ORIGINAL impl sorts n1/n2);
# the XT form is the one that reads backwards (the archive's "Texb"
# belongs to it). Archive block #771.

Scenario("Sections, forward and backward")
	o1 = new stzString("eeebxeTuniseee")
	Then("first to last is the whole",
		o1.Section(:FirstChar, :LastChar), "eeebxeTuniseee")
	Then("plain Section normalizes 7..4", o1.Section(7, 4), "bxeT")
	Then("SectionXT reads it backwards", o1.SectionXT(7, 4), "Texb")
EndScenario()

Summary()
