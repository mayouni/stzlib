# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #305.

load "../../stzBase.ring"

pr()

#                   1    2    3    4    5    6    7
o1 = new stzList([ "_", "_", "•", "_", "•", "_", "_" ])


? o1.FindNext("•", :StartingAt = 3)
#--> 5

? o1.FindNextNth(2, "•", :StartingAt = 2)
#--> 5

? o1.FindNextNth(2, "•", :StartingAt = 3)
#--> 0

? o1.FindPrevious("•", :StartingAt = 5)
#--> 3

? o1.FindPreviousNth(2, "•", :StartingAt = 7)
#--> 3

? o1.FindPreviousNth(1, "•", :StartingAt = 5)
#--> 3

? o1.FindPreviousNth(2, "•", :StartingAt = 5)
#--> 0

StopProfiler()

pf()
# Executed in 0.04 second(s) in Ring 1.22
