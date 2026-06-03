# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #4.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A1", "A2", "A3", "A4", "A5", "A6", "A7" ])

? o1.FindNextNthItem(3, :StartingAt = 4)
#--> 7

? o1.NextNthItem(3, :StartingAt = 4) + NL
#--> "A7"

#--

? o1.FindPreviousNthItem(4, :StartingAt = 7)
#--> 4

? o1.PreviousNthItem(4, :StartingAt = 7)
#--> "A4"

pf()
# Executed in almost 0 second(s) in Ring 1.21
