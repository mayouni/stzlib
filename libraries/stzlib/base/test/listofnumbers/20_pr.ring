# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #20.

load "../../stzBase.ring"


? @@( Q([1, 2, 3 ]) * 4 )
#--> [ 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3 ]

? ( Q([1, 2, 3 ]) * Q(4) ).Content()
# \___________ __________/
#             V
#       A stzList object

#--> 

pf()
# Executed in 0.02 second(s)
