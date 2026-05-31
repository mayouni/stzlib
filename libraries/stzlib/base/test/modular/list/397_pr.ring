# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #397.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1.ItemsWXT('Q(@item).IsNotANumber()')
#--> [ "A", "B", "C", "D" ]

pf()
# Executed in 0.10 second(s).
