# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #30.
#ERR Error (R20) : Calling function with extra number of parameters

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
