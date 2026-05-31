# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #2.

load "../../../stzBase.ring"


o1 = new stzList([ "C", "A", "B" ])
? o1.IsEqualTo([ "A", "B", "C" ])
#--> TRUE

? o1.IsEqualToXT([ "A", "B", "C" ])
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.24
