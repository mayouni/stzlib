# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #248.

load "../../../stzBase.ring"


? @@( "" )
#--> ""

? @@( '' )
#--> ""

? @@( '""' )
#--> '""'

? @@( "''" )
#--> "''"

? @@( "[1, 2, 3 ]" )
#--> "[1, 2, 3 ]"

? @@( '[1, 2, 3 ]' )
#--> "[1, 2, 3 ]"

? @@( '"[1, 2, 3]"' )
#--> '"[1, 2, 3]"'

? @@( "'[1, 2, 3]'" )
#--> "'[1, 2, 3]'"

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20
