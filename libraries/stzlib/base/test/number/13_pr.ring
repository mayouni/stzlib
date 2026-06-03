# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #13.

load "../../stzBase.ring"


o1 = new stzNumber(12500)

? o1 - 12000
#--> 500

? o1 - 10000 - 2000 - 250
#--> 250

? o1 - [ 10000, 2000, 250 ]
#--> 250

pf()
# Executed in 1.04 second(s)
