# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #29.

load "../../stzBase.ring"

pr()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10 ])

//o1.Flatten()
#--> Error message:
# Can't flatten the list of lists!
# Instead you can return a flattend copy of it using Flattened()

? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

pf()
# Executed in 0.04 second(s)
