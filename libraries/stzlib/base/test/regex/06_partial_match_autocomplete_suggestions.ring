# Narrative
# --------
# Partial Match: Autocomplete suggestions
#
# Extracted from stzRegexTest.ring, block #6.

load "../../stzBase.ring"


pr()

o1 = new stzRegex("(https?://)?(www\.)?[\w-]+\.com")

? o1.MatchAsYouType("www.")		#--> TRUE
? o1.MatchAsYouType("https://")		#--> TRUE
? o1.MatchAsYouType("example")		#--> TRUE
? o1.MatchAsYouType("example.")		#--> TRUE
? o1.MatchAsYouType("example.com")	#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22
