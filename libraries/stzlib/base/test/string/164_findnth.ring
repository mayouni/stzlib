# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #164.

load "../../stzBase.ring"

pr()

aList = [ 1, "♥", 3, 4, "♥", 5, "♥" ]

? FindNth(aList, 2, "♥", :StartingAt = 2)
#--> 5

? FindNth(aList, 2, "♥", :StartingAt = 3)
#--> 7

? FindNextNth(aList, 2 , "♥", :StartingAt = 2)
#--> 7

pf()
# Executed in almost 0 second(s) in Ring 1.22
