load "../../stzBase.ring"
load "../_narrated.ring"

# A trailing RUN needs the last char repeated -- ".....mmMm" ends with
# a lone case-sensitive "m" (no run), but case-insensitively the run is
# "mmMm". Archive block #668.

Scenario("The case dial changes what counts as a run")
	o1 = new stzString(".....mmMm")
	Then("case-sensitive: no trailing run", o1.HasTrailingChars(), FALSE)
	Then("... so no trailing char", o1.TrailingChar(), "")
	Then("case-insensitive: mmMm is a run",
		o1.HasTrailingCharsCS(:CaseSensitive = FALSE), TRUE)
	Then("... made of m's", o1.TrailingCharCS(FALSE), "m")
EndScenario()

Summary()
