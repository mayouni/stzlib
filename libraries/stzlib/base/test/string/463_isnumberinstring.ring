load "../../stzBase.ring"
load "../_narrated.ring"

# The global @Contains / @ContainsCS on a W-condition string.
# Archive block #463.

Scenario("Probing a condition string for its binding var")
	Then("it contains @char",
		@Contains(" Q(@char).IsNumberInString() ", "@char"), TRUE)
	Then("... but not @substring",
		@Contains(" Q(@char).IsNumberInString() ", "@substring"), FALSE)
	Then("@CHAR matches case-insensitively",
		@ContainsCS(" Q(@char).IsNumberInString() ", "@CHAR", FALSE), TRUE)
	Then("@substring stays absent, case-sensitively",
		@ContainsCS(" Q(@char).IsNumberInString() ", "@substring", TRUE), FALSE)
	Then("... and case-insensitively",
		@ContainsCS(" Q(@char).IsNumberInString() ", "@substring", FALSE), FALSE)
EndScenario()

Summary()
