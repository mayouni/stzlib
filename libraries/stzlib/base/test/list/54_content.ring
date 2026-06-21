# Narrative
# --------
# ReplaceItemByManyXT: value-addressed replace that CYCLES the palette over
# the occurrences (the "XT" twin of ReplaceByMany, block #53).
#
# "ring" occurs four times (positions 1,2,4,6); the palette [ "♥", "♥♥" ] is
# applied in a repeating cycle: ♥, ♥♥, ♥, ♥♥. Where #53 paired one palette
# entry per occurrence (1-to-1, stopping when the palette runs out), "XT"
# wraps the palette to cover every occurrence.
#
# Extracted from stzlisttest.ring, block #54.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "ring", "ruby", "ring", "python", "ring" ])
o1.ReplaceItemByManyXT("ring", [ "♥", "♥♥" ])
	
? @@( o1.Content() )
#--> [ "♥", "♥♥", "ruby", "♥", "python", "♥♥" ]

pf()
# Executed in 0.02 second(s)
