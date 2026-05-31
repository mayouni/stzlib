# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #304.

load "../../../stzBase.ring"

#                     3 5
o1 = new stzString("..•.•..")


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
# Executed in 0.03 second(s) in Ring 1.22
