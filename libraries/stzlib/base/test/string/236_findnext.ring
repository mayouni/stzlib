# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #236.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# Testing extreme cases in FindNthNext()/FindNthPrevious on a small string

StartProfiler()
#                   .2....7.9
o1 = new stzString("•••••••••")

? o1.FindNext("", :StartingAt = 1)
#--> 0

? o1.FindNext("x", :StartingAt = 1)
#--> 0

? o1.FindNext("•", :startingAt = 5)
#--> 6

? o1.FindNthNext(6, "•", :StartingAt = 3)
#--> 9

? o1.FindNthNext(5, "•", :StartingAt = 1)
#--> 6

? o1.FindPrevious("", :StartingAt = 9)
#--> 0

? o1.FindPrevious("x", :StartingAt = 1)
#--> 0

? o1.FindPrevious("•", :StartingAt = 5)
#--> 4

? o1.FindPrevious("•", :StartingAt = 2)
#--> 1

? o1.FindNthPrevious(8, "•", :StartingAt = 9)
#--> 1

? o1.FindNthPrevious(3, "•", :StartingAt = 4)
#--> 1

StopProfiler()

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.18
