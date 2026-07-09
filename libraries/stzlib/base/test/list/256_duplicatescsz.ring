# Narrative
# --------
# DuplicatesCSZ -- the case-sensitivity dial on the "duplicates with
# positions" view.
#
# Passing :CaseSensitive = FALSE folds case before grouping, so "A" and
# "a" count as the same item, as do "B" and "b". The list
# [ "A","B","A","A","C","D","B","E","a","b" ] then has two duplicated
# items: "A"/"a" at positions 3, 4, 9 (extra occurrences after the first
# "A" at position 1) and "B"/"b" at positions 7, 10. Only the EXTRA
# occurrences are listed, and the reported item keeps its original casing
# (the item found at the first of those extra positions).
#
# Extracted from stzlisttest.ring, block #256.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "A", "A", "C", "D", "B", "E", "a" , "b"])
? @@( o1.DuplicatesCSZ(:CaseSensitive = FALSE) )
#--> [ [ "A", [ 3, 4, 9 ] ], [ "B", [ 7, 10 ] ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
