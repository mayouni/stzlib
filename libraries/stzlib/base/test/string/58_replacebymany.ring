# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #58.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Replace-by-many family"): the :By
# form of ReplaceByMany has the same bug as block #48 -- it should give
# "♥ php ruby ♥♥ python ♥♥♥" but returns " php ruby ♥ python " (1st and 3rd
# occurrences dropped). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring php ruby ring python ring")
o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥" ])
? o1.Content() #--> expected "♥ php ruby ♥♥ python ♥♥♥" (currently broken)

pf()
