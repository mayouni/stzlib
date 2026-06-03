# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #937.
#ERR Error (R14) : Calling Method without definition: charsboxifiedxt

load "../../stzBase.ring"

pr()

? Q("RING").CharsBoxifiedXT([ :Numbered = TRUE ]) + NL
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘
#   1   2   3   4

? Q(Chars("RING")).ToStzListOfChars().BoxifiedXT([ :Numbered = TRUE ])
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘
#   1   2   3   4

pf()
# Executed in 0.10 second(s) in Ring 1.22
# Executed in 0.18 second(s) in Ring 1.20
