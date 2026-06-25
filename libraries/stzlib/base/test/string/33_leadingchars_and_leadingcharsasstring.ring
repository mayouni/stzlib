load "../../stzBase.ring"
load "../_narrated.ring"

# LeadingChars() / TrailingChars() return the leading (or trailing) RUN of
# identical chars as a SINGLE STRING (e.g. "---Ring" -> "---"); the XT /
# AsString / AsSubString aliases are the same. Archive block #33.
#
# NOTE: the archive #--> showed a list of chars ([ "-","-","-" ]) for the plain
# forms, but the impl deliberately returns the run as one string (see the
# doc-comment at stzString.ring ~4411). Impl is authority -> assert the string.

Scenario("The leading / trailing run as a single string")
	Given('"---Ring"')
	o1 = new stzString("---Ring")
	Then("LeadingChars() is the run as a string", o1.LeadingChars(), "---")
	Then("LeadingCharsXT() is the same", o1.LeadingCharsXT(), "---")

	Given('"Ring---"')
	o2 = new stzString("Ring---")
	Then("TrailingChars() is the trailing run", o2.TrailingChars(), "---")
	Then("TrailingCharsXT() is the same", o2.TrailingCharsXT(), "---")
EndScenario()

Summary()
