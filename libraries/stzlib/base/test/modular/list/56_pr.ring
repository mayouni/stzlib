# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #56.

load "../../../stzBase.ring"


o1 = new stzList([ "1", "♥", "♥", "4", "5", "6", "♥", "♥", "9" ])

anPos = o1.Find("♥")
#--> [ 2, 3, 7, 8 ]

o1.ReplaceAnyItemsAtPositions( o1.Find("♥"), :By = "★" )
? @@( o1.Content() )
#--> [ "1", "★", "★", "4", "5", "6", "★", "★", "9" ]

pf()
# Executed in 0.06 second(s)
