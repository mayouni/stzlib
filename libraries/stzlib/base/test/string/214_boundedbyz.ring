# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #214.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): BoundedByZ("&") / BoundedByZZ("&")
# RAISE "Incorrect param! pacBounds must be a pair of strings" -- the single-
# string bound is not widened to ["&","&"]. (And even with a pair, the Z/ZZ forms
# lose the [substring, span] grouping -- blocks 163/166/187.) Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("..&^^^&..&^^^&..&---&..&---&..")

? @@NL( o1.BoundedByZ("&") ) + NL
#--> expected each substring paired with its start position (currently raises)

? @@NL( o1.BoundedByZZ("&") )
#--> expected each substring paired with its [from,to] span (currently raises)

pf()
