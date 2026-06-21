# Narrative
# --------
# Demonstrates the "duplicate origins" family on a stzList: the first
# appearance of each value that occurs more than once.
#
# DupOrigins() returns the set of values that have duplicates, taken
# in their first-seen order -- here [ "A", "B", "C" ] (note that case
# matters, so "b" and "c" are distinct from "B" and "C" and are not
# counted as origins). FindDupOrigins() returns the positions of those
# first occurrences -- [ 1, 2, 6 ]. RemoveDupOrigins() deletes exactly
# those origin elements in place, leaving every later duplicate (and the
# case-variant singletons) untouched. This is the mirror image of the
# usual de-dup: instead of keeping the first and dropping the rest, it
# drops the first and keeps the rest.
#
# Extracted from stzlisttest.ring, block #140.

load "../../stzBase.ring"

pr()

# DupOrigins = DuplicatesOrigins

o1 = new stzList([ "A", "B", "B", "B", "b", "C", "B", "C", "C", "c", "A" ])

? o1.DupOrigins() # Same As Duplicates()
#--> [ "A", "B", "C" ]

? o1.FindDupOrigins()
#--> [ 1, 2, 6 ]

o1.RemoveDupOrigins()
? @@( o1.Content() )
#--> [ "B", "B", "b", "B", "C", "C", "c", "A" ]

pf()
# Executed in almost 0 second(s).
