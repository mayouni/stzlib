# Narrative
# --------
# Extend the string by repeating chars (a given pool, or the string's own).
#
# Extracted from stzStringTest.ring, block #139.
#

load "../../stzBase.ring"

pr()

o1 = new stzString("123")
o1.ExtendToWithCharsIn( 8, "1":"3" )
? o1.Content() #--> 12312312

pf()
