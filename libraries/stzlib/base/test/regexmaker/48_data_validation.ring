# Narrative
# --------
# Data Validation
#
# Extracted from stzregexmakertest.ring, block #48.

load "../../stzBase.ring"


pr()

o1 = new stzRegexMaker

o1.AddCommonPattern(:date)
o1.AddCharClass(:space) 
o1.AddCommonPattern(:email)

? o1.Pattern()
#--> [\s]*[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}

pf()
# Executed in almost 0 second(s) in Ring 1.22
