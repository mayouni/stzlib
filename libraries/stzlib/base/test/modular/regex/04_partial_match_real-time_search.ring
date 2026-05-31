# Narrative
# --------
# Partial Match: Real-time search
#
# Extracted from stzRegexTest.ring, block #4.

load "../../../stzBase.ring"


pr()

# MatchInProgress() is similar to MatchAsYouType() but optimized for
# searching/filtering scenarios.
# Tries to find any occurrence that could potentially match.

o1 = new stzRegex("quick.*fox")

? o1.MatchInProgress("qui")		#--> TRUR
? o1.MatchInProgress("quick br")	#--> TRUE
? o1.MatchInProgress("quick brown f")	#--> TRUE
? o1.MatchInProgress("slow")		#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22
