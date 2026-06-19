# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #155.
#ERR Error (R14) : Calling Method without definition: extendtowithitemsrepeated

load "../../stzBase.ring"

pr()

o1 = new stzList(1 : 3)
o1.ExtendToWithItemsRepeated(8)
o1.Show()
# Modernized: ExtendToWithItemsRepeated(8) extends the list TO position 8
# by cycling its own items (consistent with ExtendToWithItemsIn in 156).
# The old extracted output below assumed an "extend BY 8" semantics.
#--> [ 1, 2, 3, 1, 2, 3, 1, 2 ]

pf()
# Executed in 0.03 second(s)
