# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #269.

load "../../stzBase.ring"


o1 = new stzString("99999999999")
? o1.Spacified()
#--> 9 9 9 9 9 9 9 9 9 9 9 

? o1.SpacifiedUsing("_")
#--> 9_9_9_9_9_9_9_9_9_9_9

pf()
# Executed in 0.01 second(s)
