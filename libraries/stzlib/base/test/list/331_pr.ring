# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #331.

load "../../stzBase.ring"


o1 = new stzList([ ".",".",".",4 ,5 ,6 ,".",".","." ])
? o1.NextNItems(3, :StartingAtPosition = 3)
#--> [ 4, 5, 6 ]

? o1.PreviousNItems(3, :StartingAtPosition = 7)
#--> [ 4, 5, 6 ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
