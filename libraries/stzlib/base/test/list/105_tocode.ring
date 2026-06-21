# Narrative
# --------
# Turning a live list back into the exact Ring source code that would recreate it.
#
# Q(aList).ToCode() walks the list -- including its nested sublists and
# multibyte string items (emoji, heart) -- and returns a string that is a
# valid Ring list literal: quoted items, bracketed groups, comma separators,
# all spacing normalized. @@(aList) is the terse global alias for the same
# round-trip. This is the canonical Softanza way to serialize a structure
# for display, logging, or copy-paste back into source. Unicode codepoints
# are preserved verbatim, and nesting is reproduced to arbitrary depth.
#
# Extracted from stzlisttest.ring, block #105.

load "../../stzBase.ring"

pr()

aList = [ "1", "🌞", "1", [ "2", "♥", "2", "🌞"], "1", [ "2", ["3", "🌞"] ] ]

? Q(aList).ToCode() + NL
#--> [ "1", "🌞", "1", [ "2", "♥", "2", "🌞" ], "1", [ "2", [ "3", "🌞" ] ] ]

? @@(aList)
#--> [ "1", "🌞", "1", [ "2", "♥", "2", "🌞" ], "1", [ "2", [ "3", "🌞" ] ] ]

pf()
# Executed in 0.02 second(s)
