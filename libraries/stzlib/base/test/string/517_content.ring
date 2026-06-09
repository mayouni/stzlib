# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #517.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "C", "B" ])
o1.Move( :ItemFromPosition = 3, :To = 2 )
? o1.Content()
#--> [ "A", "B", "C" ]

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content()
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.07 second(s) in Ring 1.22
