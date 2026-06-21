# Narrative
# --------
# stzString.ToList(): list-literal expansion, with a character-split fallback.
#
# ToList() expands a string only when it actually IS a Ring list literal
# (IsListInString() -- a bracketed "[ ... ]"); otherwise it falls back to
# Chars() and returns the individual characters of the raw string. A range
# expression like ' "A" : "C" ' is plain text, not a list literal, so ToList()
# does NOT interpret the ":" as a range -- it returns every character, including
# the surrounding spaces, the quote marks, and the colon. To expand a range,
# use the L() helper or StzListQ("A":"C") instead (see blocks 384 / 385).
#
# Repositioned from test/list (stzlisttest.ring, block #383): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

? @@( Q(' "A" : "C" ').ToList() )
#--> [ " ", '"', "A", '"', " ", ":", " ", '"', "C", '"', " " ]

? @@( Q(' "ا" : "ج" ').ToList() )
#--> [ " ", '"', "ا", '"', " ", ":", " ", '"', "ج", '"', " " ]

pf()
# Executed in 0.09 second(s)
