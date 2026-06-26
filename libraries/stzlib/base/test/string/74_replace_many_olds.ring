# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #74.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Replace-by-many family"): Replace()
# is a plain 2-arg ReplaceCS (stzString.ring ~1909) with no polymorphic dispatch,
# so the documented Replace([olds], :By = new) shorthand for ReplaceMany is a
# no-op. The explicit ReplaceMany([olds], :By = new) form (block #57) works. Left
# in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString( "a + b - c / d = 0")
o1.Replace( [ "+", "-", "/" ], :By = "*" ) # Or ReplaceMany()
? o1.Content() #--> expected "a * b * c * d = 0" (currently a no-op)

pf()
