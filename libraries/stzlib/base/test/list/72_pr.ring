# Narrative
# --------
# The (-) operator: raw RHS removes ONE item; These(...) removes item-wise.
#
# This is the deliberate Softanza distinction. `Q(1:7) - 4:7` subtracts the
# sublist [4,5,6,7] as a SINGLE element -- it isn't present as one item, so
# the list is unchanged. `Q(1:7) - These(4:7)` switches to element-wise
# removal, stripping 4,5,6,7 individually and leaving [ 1, 2, 3 ]. These()
# is the explicit "spread the operand over its items" marker.
#
# Extracted from stzlisttest.ring, block #72.

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
