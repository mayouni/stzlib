# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #59.

load "../../../stzBase.ring"


o1 = new stzString("ring php ring ruby ring python ring")

o1.ReplaceByManyXT("ring", :By = [ "#1", "#2" ])
? o1.Content()
#--> "#1 php #2 ruby #1 python #2"

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.10 second(s) in Ring 1.17
