# Narrative
# --------
# ReplaceByManyXT(sub, :By = list) cycles the replacement list over every
# occurrence: with 4 "ring"s and a 2-item list, the replacements repeat #1, #2,
# #1, #2.
#
# Extracted from stzStringTest.ring, block #59.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring php ring ruby ring python ring")
o1.ReplaceByManyXT("ring", :By = [ "#1", "#2" ])
? o1.Content()
#--> #1 php #2 ruby #1 python #2

pf()
