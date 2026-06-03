# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #53.

load "../../stzBase.ring"


o1 = new stzLists([ 1:3, 1:5, 1:2 ])

? o1.Smallest()
#--> [1, 2]

? o1.SmallestSize()
#--> 2

? o1.FindSmallest()
#--> 3

? "--"

? o1.Largest()
#--> [1,2, 3, 4, 5]

? o1.LargestSize()
#--> 5

? o1.FindLargest()
#--> 2

pf()
#--> Executed in 0.03 second(s)
