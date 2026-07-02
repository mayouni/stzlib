load "../../stzBase.ring"
load "../_narrated.ring"

# The global @ReplaceCS with the case dial: case-sensitively "ring"
# misses "RING"; insensitively it hits. Archive block #462.

Scenario("Case-sensitive vs insensitive replace")
	Then("case-sensitive leaves RING alone",
		@ReplaceCS("ruby RING python", "ring", "julia", TRUE), "ruby RING python")
	Then("case-insensitive replaces it",
		@ReplaceCS("ruby RING python", "ring", "julia", FALSE), "ruby julia python")
EndScenario()

Summary()
