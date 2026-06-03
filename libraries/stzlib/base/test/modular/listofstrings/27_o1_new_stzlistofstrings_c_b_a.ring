# Narrative
# --------
# o1 = new stzListOfStrings([ "C", "B", "A" ])
#
# Extracted from stzlistofstringstest.ring, block #27.

load "../../../stzBase.ring"

o1.Move( :String = 1, :ToPositionOfString = 3)
? o1.Content() #--> [ "B", "A", "C" ]

o1.Swap(:BetweenString = 1, :AndString = 2)
? o1.Content() #--> [ "A", "B", "C" ]
