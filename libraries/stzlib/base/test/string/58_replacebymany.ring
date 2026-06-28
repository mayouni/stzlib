# Narrative
# --------
# The :By named-param form of ReplaceByMany: each "ring" maps to the next item
# in the list (multibyte replacements).
#
# Extracted from stzStringTest.ring, block #58.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring php ruby ring python ring")
o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥" ])
? o1.Content()
#--> ♥ php ruby ♥♥ python ♥♥♥

pf()
