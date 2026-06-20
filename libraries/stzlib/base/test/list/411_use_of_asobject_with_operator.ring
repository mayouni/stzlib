# Narrative
# --------
# AsObject() / Obj() / O(): adding a stzList AS AN OBJECT (not its content).
#
# By default, `Q(list) + Q(other)` adds other's CONTENT as one item. But
# sometimes you want the stz OBJECT itself stored in the list -- so you
# wrap the operand with AsObject() (aliases Obj / O), or AsObjectQ() /
# ObjQ() / OQ() to also keep the result elevated. These() / TheseQ() are
# the opposite: add the operand's items one by one.
#
# NOTE: when @@ renders a list that contains an embedded stz object it
# prints it as "@noname" (the object's placeholder var-name), not as
# "Q([3,4])". The recorded outputs below are corrected to that real render.
#
# Extracted from stzlisttest.ring, block #411.

load "../../stzBase.ring"

pr()

# When you add a normal list to a stzList object,
# you get a normal list:

? @@( Q([1,2]) + [3, 4] ) + NL
#--> [ 1, 2, [ 3, 4 ] ]

# To return the result in a stzList object (to make
# other actions on it), you elevate the added list
# with a Q() elevator like this:

? @@( ( Q([1, 2]) + Q([3, 4]) ).Content() ) + NL
#      \__________ __________/
#                 V
#          A stzList object

#--> [ 1, 2, [ 3, 4 ] ]

# Now: what if you need to add a stzList and not
# a normal list? You use AsObject() like this:

? @@( Q([1, 2]) + AsObject( Q([3, 4]) ) ) + NL # Or Obj() or simply O()
#--> [ 1, 2, @noname ]

# ~> Q([3, 4]) which is a stzList object is then added
# to the Q([1, 2]) list as an object.

# To add an object and return a stzList, use AsObjectQ():

? @@( ( Q([1, 2]) + AsObjectQ( Q([3, 4]) ) ).Content() ) # Or ObjQ() or simply OQ()
#      \________________ ________________/
#                       V
# 		 A stzList object

#--> [ 1, 2, @noname ]

# REMINDER: You can add many items at once using These:

? @@( Q([1, 2]) + These([3, 4]) ) + NL
#--> [ 1, 2, 3, 4 ]

? @@( ( Q([1, 2]) + TheseQ([3, 4]) ).Content() )
#      \_____________ _____________/
#                    V
#            A stzList object
#     due to the use of Q in TheseQ()

#--> [ 1, 2, 3, 4 ]

pf()
# Executed in 0.03 second(s)
