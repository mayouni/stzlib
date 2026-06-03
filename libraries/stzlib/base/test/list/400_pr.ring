# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #400.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

? Q(1:5) - 3
#--> [ 1, 2, 4, 5 ]

? ( Q(1:5) - Q(3) ).Content()
#--> [ 1, 2, 4, 5 ]

? Q([ "A", "B", 1:3, "C" ]) - 1:3
#--> [ "A", "B", "C" ]

? ( Q([ "A", "B", 1:3, "C" ]) - Q(1:3) ).Content()
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.02 second(s).
