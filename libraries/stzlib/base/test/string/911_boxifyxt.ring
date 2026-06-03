# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #911.
#ERR Error (R11) : Error in class name, class not found: stzlistofchars

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxifyXT([ :Rounded, :Hilight = [ 1, 4 ], :Numbered ])

pf()
# Executed in 0.07 second(s).
