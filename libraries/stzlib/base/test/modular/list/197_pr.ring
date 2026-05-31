# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #197.

load "../../../stzBase.ring"


o1 = new stzList(1:299_000+4)

? o1.FindNext(120_001, :StartingAt = 2)
#--> 120_001
# Executed in 1.53 second(s)

? o1.FindPrevious(4, :StartingAt = 180_000)
#--> 4
# Executed in 0.92 second(s)

? o1.FindNthNext(2, 4, :StartingAt = 2)
#--> 299001
# Executed in 2.82 second(s)

pf()
# Executed in Executed in 4.88 second(s)
