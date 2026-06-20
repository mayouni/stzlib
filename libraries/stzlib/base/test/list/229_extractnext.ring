# Narrative
# --------
# ExtractNext(item, :StartingAt = pos): scan FORWARD from a position for
# the next occurrence of a value, then return and remove it.
#
# "Next" means strictly after the start position: the "♥" already sitting
# at position 3 is ignored; from position 4 the next "♥" is at position 5,
# which is the one pulled out. Pairs with ExtractPrevious for cursor-style
# walking over repeated markers.
#
# Extracted from stzlisttest.ring, block #229.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

? o1.ExtractNext("♥", :StartingAt = 4)
#--> "♥"

? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, 6, "♥" ]

StopProfiler()

pf()
# Executed in almost 0 second(s)
