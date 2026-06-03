# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #16.

load "../../stzBase.ring"

pr()

o1 = new stzNumber(3000)

? o1 / 20
#--> 150

? o1 / 20 / 15 / 2
#--> 5

? o1 / [ 20, 15, 2 ]
 #--> 5

pf()
# Executed in 0.24 second(s) in Ring 1.19
