# Narrative
# --------
# o1 = new stzListOfStrings([ "C", "B", "A" ])
#
# Extracted from stzlistofstringstest.ring, block #26.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "C", "B", "A" ])

o1.Move( :StringAtPosition = 3, :ToPosition = 1 )
? o1.Content() #--> [ "A", "C", "B" ]

o1.Move( :StringAtPosition = 2, :ToPosition = 3 )
? o1.Content() #--> [ "A", "B", "C" ]

pf()
