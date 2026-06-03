# Narrative
# --------
# #todo write a #narration
#
# Extracted from stzlistofnumberstest.ring, block #17.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"


pr()

? Q([ 1, 2, 3, 4, 5]) - [1, 3 , 5]
#--> [ 1, 2, 3, 4, 5 ]
# Because [1, 3, 5 ] is not an item in the list [ 1, 2, 3, 4, 5 ]

? Q([ 1, 2, 3, [1, 3 , 5], 4, 5]) - [1, 3 , 5]
#--> [ 1, 2, 3, 4, 5 ]
# Now [ 1, 3, 5 ] is removed because it is an item from the list

# If you want to remove 1, 3, and 5 in the same statement, you use These():

? Q([ 1, 2, 3, 4, 5]) - These([1, 3 , 5])
#--> [ 2, 4 ]

# If you want to get a stzList object as an output add Q() to the second member:

//? ( Q([ 1, 2, 3, 4, 5]) - TheseQ([1, 3 , 5]) ).Content()
#  \____________________ _______________________/
#                       V
#               A stzList object

#--> [ 2, 4 ]


pf()
# Executed in 0.01 second(s) in Ring 1.21s
