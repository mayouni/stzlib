# Narrative
# --------
# ExtractWXT(condition): extract EVERY item that satisfies a W-condition
# at once -- returning all the matches and removing them from the list.
#
# The condition is a Softanza W-expression evaluated per item via @item.
# Here '{ NOT isNumber(@item) }' separates the non-numbers ("♥", "*",
# "_") out of a mixed list, leaving a clean numeric list behind -- a
# one-liner partition. Note the multibyte "♥" is handled correctly
# (codepoint-aware, not byte-sliced).
#
# Extracted from stzlisttest.ring, block #226.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", 3, "*", 4, "_" ])

? @@( o1.ExtractWXT('{ NOT isNumber(@item) }') )
#--> [ "♥", "*", "_" ]

? @@( o1.Content() )
#--> [ 1, 2, 3, 4 ]

StopProfiler()

pf()
# Executed in almost 0 second(s)
