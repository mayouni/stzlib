# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #409.
#ERR Error (E3) : Deleting scope while no scope!

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3 ])

? @IsStzObject(o1)
#--> TRUE

? @IsStzList(o1)
#--> TRUE

pf()
# Executed in 0.02 second(s).
