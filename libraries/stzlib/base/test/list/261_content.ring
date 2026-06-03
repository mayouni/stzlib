# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #261.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:7)
o1 - 4:6

? @@( o1.Content() )
#--> [ 1, 2, 3, 7 ]

pf()
# Executed in 0.03 second(s)
