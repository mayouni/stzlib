# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #490.

load "../../stzBase.ring"

pr()

? KeepingTime()
#--> FALSE

SetKeepingTimeTo(TRUE)

? KeepingTime()
#--> TRUE

pf()
