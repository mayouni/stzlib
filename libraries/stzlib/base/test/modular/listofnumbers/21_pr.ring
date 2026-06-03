# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #21.

load "../../../stzBase.ring"


? @@( Q(["A", "B" ]) * 3 )
#--> [ [ "A", "B" ], [ "A", "B" ], [ "A", "B" ] ]

? @@( ( Q(["A", "B" ]) * Q(3) ).Content() )
#     \____________ __________/
#                  V
#           A stzList object

#--> [ [ "A", "B" ], [ "A", "B" ], [ "A", "B" ] ]

pf()
# Executed in 0.02 second(s)
