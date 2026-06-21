# Narrative
# --------
# Index() on a stzListOfLists: for each distinct VALUE across all sublists,
# which sublists contain it.
#
# Here the three sublists are "A":"C"=[A,B,C], "A":"B"=[A,B], "A":"C"=[A,B,C].
# "A" and "B" appear in all three sublists (1,2,3); "C" only in the 1st and
# 3rd. So Index reports each value with the sublist indices that hold it --
# an inverted index over a list of lists.
#
# Extracted from stzlisttest.ring, block #24.

load "../../stzBase.ring"

pr()

o1 = new stzListOfLists([ "A":"C", "A":"B", "A":"C" ])
? @@( o1.Index() )
#--> [ [ "A", [ 1, 2, 3 ] ], [ "B", [ 1, 2, 3 ] ], [ "C", [ 1, 3 ] ] ]

pf()
# Executed in almost 0 second(s)
