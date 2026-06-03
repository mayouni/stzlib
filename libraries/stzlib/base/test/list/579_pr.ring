# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #579.

load "../../stzBase.ring"


# Look at this list:

o1 = new stzlist([ "a" , "b", "c", [ "a", "b", "c" ], "c" ])
#				   --------^--------
#				           |
#				       (this one)
#				           |
# If we need to remove the item at position 4 containing [ "a", "b", "c" ], we say:

? @@( o1 - [ "a", "b", "c" ] )
#--> [ "a", "b", "c", "c" ]

# But if we need to remove all the items equal to "a", "b", "c", and leave only the
# list at position 4 containing [ "a", "b", "c" ], we use These() like this:

? @@( o1 - These([ "a", "b", "c" ]) )
#--> [ [ "a", "b", "c" ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.18
