# Narrative
# --------
# ReplaceManyByManyXT: replace several items, RECYCLING a shorter
# replacement list.
#
# Four needles ("ring","softanza","kandaji","zai") are replaced by only two
# replacements ("♥","♥♥"). The "XT" form cycles the replacement list, so
# the matches get ♥, ♥♥, ♥, ♥♥ in turn -- handy for tagging groups of items
# with a small repeating palette. (Multibyte ♥ handled codepoint-safe.)
#
# Extracted from stzlisttest.ring, block #9.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "qt", "softanza", "pyhton", "kandaji", "csharp", "zai" ])
o1.ReplaceManyByManyXT([ "ring", "softanza", "kandaji", "zai" ], :By = [ "♥", "♥♥" ])

? @@( o1.Content() )
#--> [ "♥", "qt", "♥♥", "pyhton", "♥", "csharp", "♥♥" ]

pf()
# Executed in almost 0 second(s)
