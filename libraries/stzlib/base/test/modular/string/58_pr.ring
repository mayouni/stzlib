# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #58.

load "../../../stzBase.ring"


o1 = new stzString("ring php ruby ring python ring")

o1.ReplaceByMany("ring", :By = [ "♥", "♥♥", "♥♥♥" ])
? o1.Content()
#--> "♥ php ruby ♥♥ python ♥♥♥"

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.17
