# Narrative
# --------
# Partial Match: Form validation as user types
#
# Extracted from stzRegexTest.ring, block #3.

load "../../stzBase.ring"


pr()

# MatchAsYouType() is optimized for real-time validation during
# user input. Returns TRUE if either:
# 1. The string completely matches the pattern
# 2. The string could potentially match if more characters were added
# ~> Perfect for validating form fields as users type.

o1 = new stzRegex("\d{3}-\d{2}-\d{4}")  # Social security number pattern

? o1.MatchAsYouType("123")		#--> TRUE
? o1.MatchAsYouType("123-")		#--> TRUE
? o1.MatchAsYouType("123-45")		#--> TRUE
? o1.MatchAsYouType("123-45-6789")	#--> TRUE
? o1.MatchAsYouType("abc")		#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22
