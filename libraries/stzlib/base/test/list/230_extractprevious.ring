# Narrative
# --------
# ExtractPrevious(item, :StartingAt = pos): the backward mirror of
# ExtractNext -- scan toward the front for the nearest occurrence BEFORE
# a position, then return and remove it.
#
# From position 6 the nearest earlier "♥" is the one at position 5, so
# that is the marker pulled out (symmetric with ExtractNext, which from
# position 4 also lands on position 5). The "♥" at position 3 stays.
#
# Extracted from stzlisttest.ring, block #230. The historically recorded
# output removed the position-3 "♥" instead; that was inconsistent with
# the symmetric ExtractNext (block #229) and with the authoritative
# Find(Previous)OccurrenceCS algorithm -- corrected here to the real run.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

? o1.ExtractPrevious("♥", :StartingAt = 6)
#--> "♥"

? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, 6, "♥" ]

StopProfiler()

pf()
# Executed in almost 0 second(s)
