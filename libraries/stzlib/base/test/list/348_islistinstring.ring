# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #348.
#ERR Error (R11) : Error in class name, class not found: stztext

load "../../stzBase.ring"

pr()

? Q(' "A" : "C" ').IsListInString()
#--> TRUE

? QQ("C").StzType()
#--> stzchar

? QQ("12500").StzType()
#--> stznumber

? QQ("[ 1, 2, 3 ]").StzType()
#--> stzlist

? QQ("normal text").StzType()
#--> stztext

pf()
# Executed in 0.14 second(s) in Ring 1.22
