# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #372.

load "../../stzBase.ring"


o1 = new stzList([ "arem", "mohsen", "AREM" ])

? @@( o1.FindAll("arem") ) + NL
#--> [ 1 ]

? o1.FindAllCS("arem", :CS = FALSE)
#--> [1, 3]

? o1.FindNth(2, "arem")
#--> 0

? o1.FindNthCS(2, "arem", :CS = FALSE)
#--> 3

pf()
# Executed in 0.02 second(s).
