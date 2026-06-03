# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #281.

load "../../stzBase.ring"


#REMINDER // functions used internally to accelerate finding in stzLis
#~> Limited to finding only number and strings
#~> To find other types, use stzList

#                    3              6
aList = [ "_", "_", "♥", "_", "_", "♥", "_" ]

? @FindNthST(aList, 1, "♥", :StartingAt = 6)
#--> 6

? @FindNextNthST(aList, 1, "♥", :StartingAt = 6)
#--> 0

pf()
