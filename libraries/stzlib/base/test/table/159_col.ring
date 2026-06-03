# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #159.

load "../../stzBase.ring"

pr()

o1 = new stzTable([])
o1.Show()
#--> COL1
#    ----
#    ""

? @@( o1.Col(1) )
#--> [ "" ]

? @@( o1.Cell(1, 1) )
#--> ""

pf()
# Executed in 0.09 second(s)
