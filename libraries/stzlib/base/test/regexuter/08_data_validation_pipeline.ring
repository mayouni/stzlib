# Narrative
# --------
# Data Validation Pipeline
#
# Extracted from stzregexutertest.ring, block #8.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

# Shows how state helps track validation errors
*/
pr()

rxu = new stzRegexuter()

# Add validation triggers
rxu.AddTrigger(["email", "[^@]+@[^@]+\.[^@]+"])
rxu.AddTrigger(["phone", "\d{3}-\d{3}-\d{4}"])
rxu.AddTrigger(["zipcode", "\d{5}"])

# Add validation computations
rxu.AddCode("email", '{
    if NOT ( contains(@value, ".com") or contains(@value, ".org") )
        @value = "INVALID {" + @value + "}"
    ok
}')

rxu.AddCode("phone", '{
    if NOT beginswith(@value, "555")
        @value = "INVALID {" + @value + "}"
    ok
}')

# Process contact info

rxu.Process("Contact: john@email.net 123-456-7890 12345")
? @@NL( rxu.MatchesXT() ) + NL
#--> [
#	[
#		"Contact: john@email.net 123-456-7890 12345",
#		"INVALID {Contact: john@email.net 123-456-7890 12345}"
#	],
#
#	[
#		"123-456-7890",
#		"INVALID {123-456-7890}"
#	],
#
#	[ "12345", "12345" ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.22
