# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #181.
#
# DEFERRED (see _AUDIT_DEFECTS.md): two issues here. (1) The bound "\" is written
# as the Ring escape "\" in the test source, which mangles the string/bound
# literals -- the data itself is unreliable. (2) FindAsSectionsXT(sub, :Between=
# [a,b]) returns [] regardless (the :Between named-param bug, blocks 179/180/182).
# The plain FindBetweenAsSections form is the reliable one. Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("/♥♥♥\__/\/\__/♥♥♥\__")
? o1.FindBetweenAsSections("♥♥♥", "/", "\")
#--> intended [ [2, 4], [15, 17] ] (backslash-escaping makes this data unreliable)

? o1.FindAsSectionsXT( "♥♥♥", :Between = ["/","\"])
#--> :Between form returns [] (deferred)

pf()
