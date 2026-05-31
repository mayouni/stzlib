# Narrative
# --------
# #TODO
#
# Extracted from stzRegexTest.ring, block #15.

load "../../../stzBase.ring"


o1 = new stzString("[[x[2],y]]")
? o1.IsNestedUsing("[", "]")
