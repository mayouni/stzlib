# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #307.

load "../../stzBase.ring"

pr()

#                   1..4.6..9.1.34..7..0
o1 = new stzString("[••[•[••]•[•]]••[••]]")

? o1.FindNext("[", :StartingAt = 17)
#--> 0

? o1.FindPrevious("]", :StartingAt = 13)
#--> 9

StopProfiler()

pf()
# Executed in 0.01 second(s)
