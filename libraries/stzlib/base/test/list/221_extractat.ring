# Narrative
# --------
# ExtractAt(n): take the item at position n OUT of the list -- returning
# it AND removing it in one move.
#
# This is the destructive counterpart of ItemAt(n): where ItemAt only
# reads, ExtractAt mutates. The whole Extract* family follows this
# contract -- "give me X and remove it" -- which is handy for queue/stack
# style processing.
#
# Extracted from stzlisttest.ring, block #221.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "_", "B", "C" ])
? o1.ExtractAt(2) + NL
#--> "_"

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()

pf()
# Executed in almost 0 second(s)
