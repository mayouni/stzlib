# Narrative
# --------
# RingMaxRound() reports the maximum precision (in digits) at
# which Ring's floating-point compare will distinguish two
# nearly-equal numbers. On Ring 1.21 .. 1.26 the answer is 14.
#
# Extracted from stznumbertest.ring, the precision-probe block.

load "../../stzBase.ring"

pr()

? RingMaxRound()
#--> 14

pf()
