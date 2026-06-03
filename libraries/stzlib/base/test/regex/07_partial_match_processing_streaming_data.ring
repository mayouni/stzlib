# Narrative
# --------
# Partial Match: Processing streaming data
#
# Extracted from stzRegexTest.ring, block #7.

load "../../stzBase.ring"


pr()

o1 = new stzRegex("\d{2}:\d{2}:\d{2}")  # Time format

? o1.IsPartialMatch("12")		#--> TRUE
? o1.IsPartialMatch("12:")		#--> TRUE
? o1.IsPartialMatch("12:34")		#--> TRUE
? o1.IsPartialMatch("12:34:")		#--> TRUE
? o1.IsPartialMatch("12:34:56")		#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22
