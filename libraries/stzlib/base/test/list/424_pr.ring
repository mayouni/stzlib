# Narrative
# --------
# A fuller tour of the operator algebra: +, -, Q(), These(), TheseQ() --
# and the promise that the object is never mutated.
#
# `o1 + [X,Y,Z]` adds the list as a single item (like Ring), and o1 stays
# [1,2,3] afterwards. Then the chains mix elevation and item-wise ops:
# Q() makes the running result a stzList object; These() removes/adds the
# operand element by element (returning a raw list); TheseQ() does the
# element-wise op AND keeps the chain elevated. Each line is independent
# because no operator writes back to o1.
#
# Extracted from stzlisttest.ring, block #424.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3 ])

? @@( o1 + [ "X", "Y", "Z" ] )
#          \_______ _______/
#                  V
#      Like in Ring, this is added
#     as an item to end of the list

#--> [ 1, 2, 3, [ "X", "Y", "Z" ] ]

# BE CAREFUL: Object content did not change!

? o1.Content()
#--> [ 1, 2, 3 ]

? o1 + Q( "X" : "Z" ) - These([ 1, 2, 3 ])
# \________ ________/   \________ _______/
#          V                     V
#  A stzList object      Items are removed
# due to the use of       one by one from
#   Q() eleveator      the list due to These()

#--> [ "X", "Y", "Z" ]


? o1 - Q("X":"Z") + These([ 4, 5 ]) + 6
# \_______________ _______________/
#                 V
#      A normal Ring list due
#        the use of These()

#--> [ 1, 2, 3, 4, 5, 6 ]

? o1 - Q(1) - Q(2) - TheseQ([ 3, 6 ]) + These([ "X", "Y", "Z" ])
# \________________ ________________/
#                  V
#           A stzList object
#      due to the use of TheseQ()

#--> [ "X", "Y", "Z" ]

pf()
# Executed in 0.04 second(s)
