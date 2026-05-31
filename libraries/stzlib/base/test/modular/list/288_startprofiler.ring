# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #288.

load "../../../stzBase.ring"

#                   1    2      3      4      5     6     7      8     9    10
o1 = new stzList([ "_", "_", "A":"C", "_", "A":"C", "_", "_", "A":"C", "_", "_" ])
? o1.FindNth(3, "A":"C")
#--> 8

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.15 second(s) in Ring 1.20
