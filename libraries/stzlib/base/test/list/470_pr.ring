# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #470.

load "../../stzBase.ring"


oList = new stzList([ [1],[1],[1],[1] ])
? oList.ItemsHaveSameType()
#--> TRUE

? oList.ItemsAreEmptyLists()
#--> FALSE

pf()
# Executed in almost 0 second(s).
