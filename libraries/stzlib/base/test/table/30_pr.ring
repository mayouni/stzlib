# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #30.

load "../../stzBase.ring"

pr()

o1 = new stzTable([ [ 10, "ten" ], [ 20, "twenty" ] ])
o1.Show()
#-->
#	COL1     COL2
#	----- -------
#	  10      ten
#	  20   twenty

pf()
# Executed in 0.07 second(s)
