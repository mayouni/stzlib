# Narrative
# --------
# PreviousNthOccurrence(n, :Of = item, :StartingAt = pos): walk BACKWARD
# from a position and return the position of the n-th earlier occurrence.
#
# In [ 0, 8, 0, 0, 1, 8, 0, 0 ], starting at position 5 and going back,
# the 0s sit at 4 (1st previous) and 3 (2nd previous) -> 3. The second
# call counts the 8s backward from the last item: 6 (1st), 2 (2nd) -> 2.
# :StartingAt also accepts the :LastItem token for "from the very end".
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
# Executed in almost 0 second(s)
