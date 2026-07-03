load "../../stzBase.ring"
load "../_narrated.ring"

# HasLeadingChars / LeadingCharsXT / LeadingCharsRemoved.
# Archive block #676.

Scenario("Leading zeros of 000122.12")
	o1 = new stzString("000122.12")
	Then("there is a leading run", o1.HasLeadingChars(), TRUE)
	Then("the run as a string", o1.LeadingCharsXT(), "000")
	Then("the string without it", o1.LeadingCharsRemoved(), "122.12")
EndScenario()

Summary()
