# Narrative
# --------
# Ring number() VS Softanza @Number()
#
# Extracted from stzregexmakertest.ring, block #13.

load "../../../stzBase.ring"


pr()

? number("12 120.5")
#--> 12

? @Number("12 120.5") + NL
#--> 12120.50

#--

//? number("12_120.5")
#--> ERROR: Invalid numeric string

? @Number("12_120.5")
#--> 12120.50

pf()
# Executed in almost 0 second(s) in Ring 1.22

#---

pr()

? IsNumberInString("-12120.5")
#--> TRUE

? IsNumberInString("-12 120.5")
#--> TRUE

? IsNumberInString("-12_120.5")
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22
