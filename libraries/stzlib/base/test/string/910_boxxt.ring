# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #910.
#ERR Error (R11) : Error in class name, class not found: stzlistofchars

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxXT([ :Rounded, :Hilight = [ 1, 4 ], :NumberedXT ])

pf()
