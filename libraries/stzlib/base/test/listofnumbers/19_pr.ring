# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #19.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

? Q([1, 2, 3 ]) + 4
#--> [ 1, 2, 3, 4 ]

? ( Q([1, 2, 3 ]) + Q(4) ).Content()
# \___________ __________/
#             V
#         A StzList object

# [ 1, 2, 3, 4 ]

pf()
# Executed in 0.02 second(s)
