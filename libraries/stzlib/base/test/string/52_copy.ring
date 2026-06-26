load "../../stzBase.ring"
load "../_narrated.ring"

# Copy() returns an independent stzString, so a chain of mutating Q-ops sculpts
# the copy while the original is untouched. Archive block #52.
#
# NOTE: the archive #--> "I*L*R" dropped one "I" (a copy typo); "ilir" has two
# i's, so the correct result is "I*L*I*R".

Scenario("Sculpting a copy leaves the original intact")
	Given('"ilir"')
	o1 = new stzString("ilir")
	Then("Copy().Uppercase.Spacify.Replace(' ','*') -> I*L*I*R",
		o1.Copy().UppercaseQ().SpacifyQ().ReplaceQ(" ", "*").Content(), "I*L*I*R")
	Then("the original is unchanged", o1.Content(), "ilir")
EndScenario()

Summary()
