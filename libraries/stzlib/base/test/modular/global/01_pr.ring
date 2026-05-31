# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #1.

load "../../../stzBase.ring"


? IsStzFindable("ring")
#--> FALSE

? IsStzFindable(1:20)
#--> FALSE

? IsStzFindable( Q("ring") ) # because Q() elevates "ring" to a stzString object
#--> TRUE

? IsStzFindable( Q(1:20) ) # because Q() elevates 1:20 to a stzList object
#--> TRUE

? IsStzFindable( ANullObject() ) # it's a stzObject but it is not findable!
#--> FALSE

pf()
# Executed in 0.02 second(s)
