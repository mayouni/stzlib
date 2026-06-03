# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #932.
#ERR Error (R11) : Error in class name, class not found: stzlistofchars

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars([ "R", "I", "G", "N", "G" ])

? o1.BoxifyXT([ :Hilight = [ 1, 2, 4, 5 ], :Sectioned=FALSE, :Numbered ])
#-->
# ┌───┬───┬───┬───┬───┐
# │ R │ I │ G │ N │ G │
# └─•─┴─•─┴───┴─•─┴─•─┘
#   1   2       4   5

pf()
# Executed in 0.10 second(s).
