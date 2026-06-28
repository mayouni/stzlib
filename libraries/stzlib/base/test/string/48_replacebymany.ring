# Narrative
# --------
# ReplaceByMany(sub, [r1, r2, r3]) replaces each successive occurrence of `sub`
# with r1, r2, r3 in turn (cycling if there are more occurrences than
# replacements). Each "ring" maps to the next item in the list.
#
# Extracted from stzStringTest.ring, block #48.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring php ruby ring python ring")
o1.ReplaceByMany("ring", [ "X", "XX", "XXX" ])

? o1.Content()
#--> X php ruby XX python XXX

pf()
