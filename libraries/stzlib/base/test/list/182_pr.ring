# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #182.

load "../../stzBase.ring"


o1 = new stzList(1:10)
? @@( o1.Section(3, 10) )
#--> [ 3, 4, 5, 6, 7, 8, 9, 10 ]

pf()
# Executed in 0.03 second(s)
