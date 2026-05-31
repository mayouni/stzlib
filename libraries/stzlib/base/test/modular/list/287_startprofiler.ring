# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #287.

load "../../../stzBase.ring"

#                   1    2    3    4    5    6    7    8    9   10
o1 = new stzList([ "_", "_", "♥", "_", "♥", "_", "_", "♥", "_", "_" ])
? o1.FindNth(3, "♥")
#--> 8

StopProfiler()
# Executed in 0.01 second(s)
