# Narrative
# --------
# Finding every position where a value occurs in a list, and slicing
# that set of positions from either end with optional anchors.
#
# FindAll returns all positions of "abc" in the list. The occurrence
# family then refines this: NFirstOccurrences / NLastOccurrences take the
# first or last N hits, while the *ST variants add a :StartingAt anchor so
# the scan begins at a given position. These methods are abstracted in
# stzObject, so they behave identically for stzString and stzListOfStrings.
# Note the two spellings NLastOccurrencesST and LastNOccurrencesST both
# resolve to the same last-N-from-start-position behavior.
#
# Extracted from stzlisttest.ring, block #337.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "2", "abc", "4", "5", "abc", "7", "8", "abc" ])

? o1.FindAll("abc")
#--> [ 3, 6, 9 ]

#NOTE: the following functions work the same for stzString and
# stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = "abc") 
#--> [ 3, 6 ]

? o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 1)
#--> [ 3, 6 ]

? o1.NLastOccurrences(2, :Of = "abc")
#--> [ 6, 9 ]

? o1.NLastOccurrencesST(2, "abc", :StartingAt = 1)
#--> [ 6, 9 ]

? o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 6)
#--> [ 6, 9 ]

? o1.LastNOccurrencesST(1, :Of = "abc", :StartingAt = 9)
#--> [ 9 ]

pf()
# Executed in 0.06 second(s).
