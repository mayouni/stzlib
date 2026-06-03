# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #910.

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxXT([ :Rounded, :Hilight = [ 1, 4 ], :NumberedXT ])

pf()
