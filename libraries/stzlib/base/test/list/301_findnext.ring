# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #301.

load "../../stzBase.ring"

pr()

#                     3 5
o1 = new stzString("12•4•67")

? o1.FindNext("•", :StartingAt = 3)
#--> 5

? o1.FindNextNth(2, "•", :StartingAt = 3)
#--> 5

? o1.FindPrevious("•", :StartingAt = 5)
#--> 3

? o1.FindPreviousNth(2, "•", :StartingAt = 5)
#--> 3

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.20
