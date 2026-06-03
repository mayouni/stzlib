# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #165.

load "../../stzBase.ring"

pr()

? @ListContainsCS([ "hi!", "--♥♥♥--♥♥♥--" ], "hi!", TRUE)
#--> TRUE

? @FindNthSTCS([ "hi!", "--♥♥♥--♥♥♥--" ], 1, "hi!", :StartingAt = 1, TRUE)
#--> 1

? Q([ "hi!", "--♥♥♥--♥♥♥--" ]).ContainsCS("hi!", 1)
#--> 1

pf()
# Executed in 0.01 second(s) in Ring 1.22
