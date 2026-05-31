# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #456.

load "../../../stzBase.ring"


o1 = new stzList([ "teeba", "hussein", "haneen" , "hussein" ])

? o1.DuplicatesRemoved()
#--> [ "teeba", "hussein", "haneen" ])

? o1.NumberOfItems()
#--> 4

pf()
# Executed in almost 0 second(s).
