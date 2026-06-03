# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #488.

load "../../stzBase.ring"

pr()

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )

? o1.PreviousNthOccurrence(2, :Of = 0, :StartingAt = 5)
#--> 3

? o1.PreviousNthOccurrence(2, :Of = 8, :StartingAt = :LastItem)
#--> 2

pf()
# Executed in 0.11 second(s).
