# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #332.

load "../../../stzBase.ring"


o1 = new stzList([ 7, 3, 3, 10, 8, 8 ])

? o1.Smallest()
#--> 3

? o1.Largest()
#--> 10

? @@( o1.FindSmallest() )
#--> [2, 3]

? o1.NumberOfOccurrencesOfSmallestItem()
#--> 2

# or more simply

? o1.NumberOfSmallest()
#--> 2

? @@( o1.FindLargest() )
#--> [ 4 ]

? o1.NthSmallest(3)
#--> 8

? @@( o1.FindNthSmallest(3) )
#--> [ 5, 6 ]

pf()
# Executed in 0.01 second(s).
