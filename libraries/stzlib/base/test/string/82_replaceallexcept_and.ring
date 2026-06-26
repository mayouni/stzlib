# Narrative
# --------
# #expressiveness #elegant-code
#
# Extracted from stzStringTest.ring, block #82.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Except family"): the
# ReplaceAllExcept([ "Ring", :And = "Softanza" ], :With = ...) named-param form
# does not parse the :And keep-token, so "Softanza" is replaced too -- giving
# "♥♥Ring♥♥♥♥♥♥♥♥♥♥♥♥♥♥" instead of the intended "♥Ring♥Softanza♥". Left in
# print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("--Ring--__Softanza__")
o1.ReplaceAllExcept([ "Ring", :And = "Softanza" ], :With = AHeart())
? o1.Content() #--> expected "♥Ring♥Softanza♥" (currently keeps neither run granularity nor Softanza)

pf()
