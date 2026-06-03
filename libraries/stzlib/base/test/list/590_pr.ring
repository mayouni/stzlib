# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #590.

load "../../stzBase.ring"


o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT(:ToPosition = 5, :With = "0") # Or ExtendToWith()
? o1.Content()
#--> [ "A", "B", "C", "0", "0" ]

pf()
# Executed in almost 0 second(s).
