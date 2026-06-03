# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #50.
#ERR Error (R14) : Calling Method without definition: ismarquer

load "../../stzBase.ring"

pr()

? IsMarquer("#01")
#--> TRUE

? IsMarquer("#02")
#--> TRUE

? BothAreMarquers("#01", "#02")
#--> TRUE

pf()
# Executed in 0.01 second(s)
