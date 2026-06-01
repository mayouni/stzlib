# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #605.

load "../../../stzBase.ring"


? Q("...").Marquer()
#--> "#"

? Q("#12500").IsMarquer()
#--> TRUE

? @@( Q("#12500").Marquers() )
#--> [ "12500" ]

pf()
# Executed in 0.02 second(s).
