# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #57.
#ERR Error (R3) : Calling Function without definition: fill

load "../../stzBase.ring"

pr()

o1 = StzTableQ([ 3, 3 ]) { Fill(:With = "A") }
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       A      A      A
#       A      A      A

pf()
# Executed in 0.10 second(s) in Ring 1.20
# Executed in 0.48 second(s) in Ring 1.17
