# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #103.
#

load "../../stzBase.ring"

pr()

o1 = new stzString("123♥♥678♥♥1234♥♥789")

? o1.ContainsXT( "♥", :InSection = [ 3, 10 ] )                          #--> TRUE
? o1.ContainsXT( "♥", :InSections = [ [ 3, 10 ], [ 8, 12 ], [ 14, 19 ] ] ) #--> TRUE

pf()
