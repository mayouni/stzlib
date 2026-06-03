# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #93.

load "../../stzBase.ring"


aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 1_000_000 # test it with 1_000, 10_000, and 100_000 times
	aLargeList + "ring"
next

o1 = new stzList(aLargeList)
o1.StringifyAndReplaceXT("_", "*")
? @@( o1.Content()[2] )
#--> [1, 3]

pf()
# Executed in 20.31 second(s) in Ring 1.22
# Executed in 19.96 second(s) in Ring 1.21


#   SIZE    | Ring 1.17 | Ring 1.18 | Ring 1.19 | Ring 1.19 X64
#-----------+-----------+-----------+-----------+---------------
#     1_000 |   0.08 s  |   0.07 s  |   0.06 s  |   0.07 s
#    10_000 |   0.50 s  |   0.48 s  |   0.25 s  |   0.23 s
#   100_000 |   4.83 s  |   4.58 s  |   2.24 s  |   2.04 s
# 1_000_000 | 114.89 s  | 114.80 s  |  43.73 s  |  38.21 s
#-----------+-----------+-----------+-----------+---------------
