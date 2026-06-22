# Narrative
# --------
# FindNthNextOccurrence finds the position of the Nth occurrence of a
# value, scanning forward from a chosen start index.
#
# Here the list [122, 67, 120, 58, 101, 120] contains the value 120 at
# positions 3 and 6. Asking for the 2nd occurrence (:Of = 120) while
# StartingAt = 1 walks the list left-to-right and returns 6, the index
# of that second hit. The named-argument form (:Of, :StartingAt) reads
# like a sentence and lets you anchor the count to any window of the
# list rather than always counting from the head.
#
# Extracted from stzlisttest.ring, block #490.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])

? o1.FindNthNextOccurrence( 2, :Of = 120, :StartingAt = 1 ) #--> 6
#--> 6

pf()
# Executed in almost 0 second(s).
