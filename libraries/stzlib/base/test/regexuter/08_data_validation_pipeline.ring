# Narrative
# --------
# Data Validation Pipeline
#
# Extracted from stzregexutertest.ring, block #8.

load "../../stzBase.ring"

# Shows how state helps track validation errors

pr()

rxu = new stzRegexuter()

# Add validation triggers
rxu.AddTrigger(["email", "[^@]+@[^@]+\.[^@]+"])
rxu.AddTrigger(["phone", "\d{3}-\d{3}-\d{4}"])
rxu.AddTrigger(["zipcode", "\d{5}"])

# Add validation computations
rxu.AddCode("email", func v {
    if NOT ( contains(v, ".com") or contains(v, ".org") )
        v = "INVALID {" + v + "}"
    ok
    return v
    })

rxu.AddCode("phone", func v {
    if NOT beginswith(v, "555")
        v = "INVALID {" + v + "}"
    ok
    return v
    })

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
