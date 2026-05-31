# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #380.

load "../../../stzBase.ring"


o1 = new stzList([ 1:3, 4:6, 1:3, 1:3, 4:6, 7:10 ])

? o1.FindAll(1:3)
#--> [1, 3, 4]

? o1.Contains(7:10)
#--> TRUE	

pf()
# Executed in 0.02 second(s).
