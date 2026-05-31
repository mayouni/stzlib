# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #105.

load "../../../stzBase.ring"


aList = [ "1", "🌞", "1", [ "2", "♥", "2", "🌞"], "1", [ "2", ["3", "🌞"] ] ]

? Q(aList).ToCode() + NL
#--> [ "1", "🌞", "1", [ "2", "♥", "2", "🌞" ], "1", [ "2", [ "3", "🌞" ] ] ]

? @@(aList)
#--> [ "1", "🌞", "1", [ "2", "♥", "2", "🌞" ], "1", [ "2", [ "3", "🌞" ] ] ]

pf()
# Executed in 0.02 second(s)
