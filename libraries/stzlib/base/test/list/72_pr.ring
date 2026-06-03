# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #72.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

? Q(1:7) - 4:7
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

? Q(1:7) - These(4:7)
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.06 second(s) in Ring 1.19 (64 bits)
# Executed in 0.05 second(s) in Ring 1.19 (32 bits)
# Executed in 0.04 second(s) in Ring 1.17
