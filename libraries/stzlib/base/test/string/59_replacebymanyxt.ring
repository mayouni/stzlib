# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #59.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Replace-by-many family"):
# ReplaceByManyXT(sub, :By = list) should cycle the replacement list over every
# occurrence ("ring php ring ruby ring python ring" -> "#1 php #2 ruby #1 python
# #2"), but it is broken (returns " php #1 ruby  python #2"). Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring php ring ruby ring python ring")
o1.ReplaceByManyXT("ring", :By = [ "#1", "#2" ])
? o1.Content() #--> expected "#1 php #2 ruby #1 python #2" (currently broken)

pf()
