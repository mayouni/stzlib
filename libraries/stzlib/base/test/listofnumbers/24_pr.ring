# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #24.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

? @@( Q([4, 44, 444 ]) / 3 )
#--> [ [ 4 ], [ 44 ], [ 444 ] ]

? @@( ( Q([4, 44, 444 ]) / Q(3) ).Content() )
#      \____________ ___________/
#                   V
#           a stzList object

#--> [ [ 4 ], [ 44 ], [ 444 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
