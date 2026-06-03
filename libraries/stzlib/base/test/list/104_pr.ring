# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #104.

load "../../stzBase.ring"


? isNumber([ "'" ])
#--> FALSE

? @@( "🌞" )
#--> "🌞"

? @@([ 1, 2 ])
#--> [ 1, 2 ]

? @@([ '"' ])
#--> [ '"' ]

? @@([ "'" ])
#-->[ "'" ]

? @@([ "1", "🌞", "ring" ])
#--> [ "1", "🌞", "ring" ]

pf()
# Executed in 0.02 second(s)
