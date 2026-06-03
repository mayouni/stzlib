# Narrative
# --------
# #TODO
#
# Extracted from stzRegexTest.ring, block #15.
#ERR Error (R14) : Calling Method without definition: isnestedusing

load "../../stzBase.ring"

pr()

o1 = new stzString("[[x[2],y]]")
? o1.IsNestedUsing("[", "]")

pf()
