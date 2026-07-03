load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsMoreThenN (the archive's spelling) vs ContainsNTimes.
# Archive block #507.

Scenario("Counting occurrences")
	o1 = new stzString("ab_cd_ef_gh")
	Then("more than one underscore", o1.ContainsMoreThenN(1, "_"), TRUE)
	Then("not more than one a", o1.ContainsMoreThenN(1, "a"), FALSE)
	Then("exactly one a", o1.ContainsNTimes(1, "a"), TRUE)
EndScenario()

Summary()
