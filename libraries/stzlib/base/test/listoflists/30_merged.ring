# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #30.

load "../../stzBase.ring"

pr()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10 ])

//o1.Merge()
#--> Error message:
# Can't merge the list of lists!
# Instead you can return a merged copy of it using Merged()

? @@( o1.Merged() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

pf()
# Executed in 0.03 second(s)

#NOTE: You will understand the difference between Flatten() and Merge()
# by reading the fellowing two ewxamples...
