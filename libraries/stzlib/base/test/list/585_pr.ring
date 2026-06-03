# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #585.

load "../../stzBase.ring"

pr()

? @@( Q([ 3, 6, 9 ]) / 3 )
#     \_____ _____/
#           V
#    A stzList object

#--> [ [ 3 ], [ 6 ], [ 9 ] ]

? @@( QQ([ 3, 6, 9 ]) / 3 ) + NL
#     \______ _____/
#            V
#     A stzListOfNumber object

#--> [ 1, 2, 3 ]

# In both examples above, You can return
# stzList object instead of a normal list:

? ( Q([ 3, 6, 9 ]) / Q(3) ).StzType()
#--> stzlist

? ( QQ([ 3, 6, 9 ]) / Q(3) ).StzType()
#--> stzlistofnumbers

pf()
# Executed in 0.04 second(s).
