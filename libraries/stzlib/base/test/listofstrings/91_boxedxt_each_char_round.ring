# Narrative
# --------
# BoxedXT with :EachChar = TRUE wraps each character of the
# source string in its own cell, and :AllCorners = :Round picks
# the round-corner glyphs (╭╮╰╯ instead of +).
#
# Extracted from stzlistofstringstest.ring, the per-char round-
# corner box block. Box-drawing chars are Softanza's visual
# identity -- preserved verbatim.

load "../../stzBase.ring"

pr()

? StzStringQ("CAIRO").BoxedXT([ :EachChar = TRUE, :AllCorners = :Round ])

#--> 	╭───┬───┬───┬───┬───╮
# 	│ C │ A │ I │ R │ O │
# 	╰───┴───┴───┴───┴───╯

pf()
