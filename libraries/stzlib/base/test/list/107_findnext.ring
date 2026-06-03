# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #107.

load "../../stzBase.ring"

pr()

o1 = new stzlist(1:120_000)

? o1.FindNext(3, :StartingAt = 10)
#--> 0

? o1.FindNext(10, :StartingAt = 10)
#--> 0

? o1.FindNext(11, :StartingAt = 10)
#--> 11

? o1.FindNext(100_000, :StartingAt = 70_000)
#--> 100_000

#--

? o1.FindPrevious(10, :StartingAt = 5)
#--> 0

? o1.FindPrevious(10, :StartingAt = 10)
#--> 0

? o1.FindPrevious(7, :StartingAt = 10)
#--> 7

? o1.FindPrevious(110_000, :StartingAt = 112_000)
#--> 110000

pf()
# Executed in 0.61 second(s) in Ring 1.19 (64 bits)
# Executed in 0.67 second(s) in Ring 1.19 (32 bits)
# Executed in 2.06 second(s) in Ring 1.18
# Executed in 2.19 second(s) in Ring 1.17
