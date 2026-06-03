# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #14.

load "../../stzBase.ring"


o1 = new stzNumber(12)

? o1 * 5
#--> 60

? o1 * 5 * 4 * 2
#--> 480

? o1 * [ 5, 4, 2 ]
 #--> 480

pf()
# Executed in 0.83 second(s)
