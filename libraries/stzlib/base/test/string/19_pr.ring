# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #19.

load "../../stzBase.ring"


o1 = new stzList(1:8)

? o1.Section(3, 5)
#--> [ 3, 4, 5 ]

? o1.Section(5, 3)
#--> [ 3, 4, 5 ]

pf()
# Executed in 0.01 second(s)
