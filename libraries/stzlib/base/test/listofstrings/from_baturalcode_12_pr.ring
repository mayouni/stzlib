# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #12.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "Ring", "Ruby" ])
? o1.FirstChar()
#--> "R"

o1 = new stzListOfStrings([ "Ring", "Bing" ])
? o1.LastChar()
#--> "g"

pf()
# Executed in 0.01 second(s) in Ring 1.23
