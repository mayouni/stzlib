# Narrative
# --------
# #TODO
#
# Extracted from stzlisttest.ring, block #333.

load "../../../stzBase.ring"


pr()

o1 = new stzList([ ".", ".", "3", "4", ".", ".", "7", "8", "9", ".", "." ])

? o1.YieldXT( '@item', :FromPosition = 4, :To = -3)
#--> [ ".", ".", "7", "8", "9" ]

? o1.YieldXT( '@char', :StartingAt = 3, :Until = ' @item = "." ' )
#--> [ "3", "4" ]

? o1.YieldXT( '@char', :StartingAt = 3, :UntilXT = ' @item = "." ' )
#--> [ "3", "4", "." ]

pf()
