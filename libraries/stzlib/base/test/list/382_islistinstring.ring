# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #382.

load "../../stzBase.ring"

pr()

? Q(' [ "A", "B", 3 ] ').IsListInString()
#--> TRUE

? Q(' 1 : 3 ').IsListInString()
#--> TRUE

? Q(' "A" : "C" ').IsListInString()
#--> TRUE

? Q(' "ا" : "ج" ').IsListInString()
#--> TRUE

pf()
# Executed in 0.07 second(s).
