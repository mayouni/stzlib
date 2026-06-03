# Narrative
# --------
# #  Email Processing  #
#
# Extracted from stzRegexTest.ring, block #43.

load "../../stzBase.ring"

#--------------------#

pr()

emailText = "Contact us at support@example.com or john.doe+label@sub.domain.co.uk
Invalid emails: missing@domain, @nodomain.com, just.text"

o = new stzRegex("")

# Basic email validation

o.SetPattern("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")

? o.Match("support@example.com")
#--> TRUE

? o.Match("invalid@email")
#--> FALSE

# Advanced email parsing

o.SetPattern("(?<user>[a-zA-Z0-9._%+-]+)@(?<domain>[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})")

if o.Match("john.doe+label@sub.domain.co.uk") and o.HasNames()
    ? @@NL(o.CaptureXT())
ok
#--> [
#	[ "user", "john.doe+label" ],
#	[ "domain", "sub.domain.co.uk" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
