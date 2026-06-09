# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #548.
#ERR exit 1

load "../../stzBase.ring"

pr()

o1 = new stzList(["_", "A", "*", "_", "B", "*", "_", "C", "*" ])

? o1.FindWXT( :Where = ' @NextItem = "*" ' )
#--> [ 2, 5, 8 ]

? o1.ItemsWXT( :Where = ' @NextItem = "*" ' )
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.20 second(s).
