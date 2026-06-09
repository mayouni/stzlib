# Narrative
# --------
# #narration Use of AsObject() with + operator
#
# Extracted from stzlisttest.ring, block #411.
#ERR Error (R13) : Object is required

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
#--> [ 1, 2, Q([3,4]) ]

# ~> Q([3, 4]) which is is a stzList object is then added
# to the Q([1, 3]) list as an object.

# To add an object and return a stzList, use AsObjectQ():

? @@( ( Q([1, 2]) + AsObjectQ( Q([3, 4]) ) ).Content() ) # Or ObjQ() or simply OQ()
#      \________________ ________________/
#                       V
# 		 A stzList object

#--> [ 1, 2, Q([3,4]) ]

# REMINDER: You can add many items at once using These:

? @@( Q([1, 2]) + These([3, 4]) ) + NL
#--> [ 1, 2, 3, 4 ]

? @@( ( Q([1, 2]) + TheseQ([3, 4]) ).Content() )
#      \_____________ _____________/
#                    V
#            A stzList object
#     due to the use of Q in TheseQ()

#--> [1, 2, 3, 4 ]

pf()
# Executed in 0.03 second(s).
