# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #287.
#ERR Error (R14) : Calling Method without definition: findnth

load "../../stzBase.ring"

pr()

#                   1    2    3    4    5    6    7    8    9   10
o1 = new stzList([ "_", "_", "♥", "_", "♥", "_", "_", "♥", "_", "_" ])
? o1.FindNth(3, "♥")
#--> 8

StopProfiler()

pf()
# Executed in 0.01 second(s)
