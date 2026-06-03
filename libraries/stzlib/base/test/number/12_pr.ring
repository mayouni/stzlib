# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #12.

load "../../stzBase.ring"


o1 = new stzNumber(3200)

? o1 + 3500
#--> 3600

? o1 + 300 + 500 + 200
#--> 4200

? o1 + [ 300, 500, 200 ]
 #--> 4200

pf()
# Executed in 1.03 second(s)
