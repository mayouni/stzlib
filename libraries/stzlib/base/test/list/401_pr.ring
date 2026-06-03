# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #401.

load "../../stzBase.ring"


o1 = new stzList([ 1, "A":"B", 2, 3, "X", "Y", "Z" ])

? o1 - "A":"B"
# \____ ____/
#      V
#  A normal Ring list

#--> [ 1, 2, 3, "X", "Y", "Z" ]

? o1 - Q("A":"B") - These([ "X", "Y", "Z" ])
# \______ _____/
#        V
#  A stzList object due to the use of Q("A":"B")

#--> [ 1, 2, 3 ]


? o1 - Q("A":"B") - These([ "X", "Y", "Z" ]) + 4
# \___________________ ___________________/
#                     V
#             A normal Ring list
#         due to the use of These()

#--> [ 1, 2, 3, 4 ]

? o1 - Q("A":"B") - TheseQ([ "X", "Y", "Z" ]) + These([ 4, 5 ])
# \___________________ ____________________/
#                     V
#             A stzList object
#        due to the use of TheseQ()

#--> [ 1, 2, 3, 4, 5 ]

pf()
# Executed in 0.01 second(s).
