# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #97.

load "../../stzBase.ring"

pr()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 10_000
	aLargeList + "ring"
next
aLargeList + "--_--" + "--_--"

o1 = new stzList(aLargeList)
o1.StringifyAndReplaceXT("_", "♥")
? o1.Content()[2]
#--> [1, 3, 1005, 1006]

pf()
# Executed in 0.21 second(s) in Ring 1.22
# Executed in 0.50 second(s) in Ring 1.20
