# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #25.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", "A", "C", "D", "B", "b" ])
? o1.ItemsOccuringNTimesCS(3, FALSE) #NOTE this is a misspelled form (one r instead of 2)
#--> [ "b" ]

pf()
