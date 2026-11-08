# Narrative
# --------
# Finding and Processing Emails
#
# Extracted from stzregexutertest.ring, block #5.

load "../../stzBase.ring"


pr()

rxuter() {

	# Step 1: Watch for email patterns

	AddTrigger(:EmailFound = "(\w+)@(\w+\.\w+)")

	# Step 2: Define how to process found emails -- a function of the
	# matched value (Haro runs no text as code)

	AddComputation( :When = :EmailFound, :Do = func cMatch {
	          return StzStringQ(cMatch).Split('@')[2]
	})

	# Step 3: Process text containing emails

	Process("Contact us at support@example.com or sales@example.com")

	? @@NL( MatchesAndTheirResults() ) # or simply MatchesXT()
	#--> [
	# 	[ "support@example.com", "example.com" ],
	# 	[ "sales@example.com", "example.com" ]
	# ]

}

pf()
# Executed in 0.03 second(s) in Ring 1.22
