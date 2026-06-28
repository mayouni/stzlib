# Narrative
# --------
# Extend the string by repeating chars (a given pool, or the string's own).
#
# Extracted from stzStringTest.ring, block #142.
#

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :With = :CharsRepeated )
o1.Show()
#--> ABCAB

pf()
