# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #139.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Extend family"):
# ExtendToWithCharsIn(8, "1":"3") returns the string UNCHANGED ("123") instead of
# repeating the chars in the range up to width 8 ("12312312"). The sibling
# ExtendToWithCharsRepeated(8) (block #138) works. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("123")
o1.ExtendToWithCharsIn( 8, "1":"3" )
? o1.Content() #--> expected "12312312" (currently "123")

pf()
