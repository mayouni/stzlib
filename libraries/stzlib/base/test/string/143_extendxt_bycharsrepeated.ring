# Narrative
# --------
# Extend the string by repeating chars (a given pool, or the string's own).
#
# Extracted from stzStringTest.ring, block #143.
#

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :ByCharsRepeated )
o1.Show()
#--> ABCAB

pf()
