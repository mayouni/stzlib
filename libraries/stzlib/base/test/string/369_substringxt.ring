# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #369.

load "../../stzBase.ring"

pr()

? Q(".. ♥♥ring♥♥ ..").SubStringXT("♥♥", :IsBoundOf = "ring")
#--> TRUE

? Q(".. <<ring>> ..").SubStringXT("<<", :IsFirstBoundOf = "ring")
#--> TRUE

? Q(".. <<ring>> ..").SubStringXT(">>", :IsLastBoundOf = "ring")
#--> TRUE

? Q(".. <<ring>> ..").SubStringXT("<<", :IsLeftBoundOf = "ring")
#--> TRUE

? Q(".. <<ring>> ..").SubStringXT(">>", :IsRightBoundOf = "ring")
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.21
