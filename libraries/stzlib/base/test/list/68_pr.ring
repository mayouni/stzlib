# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #68.

load "../../stzBase.ring"


o1 = new stzString("♥♥♥123♥♥♥")
o1.TrimChar("♥")
? o1.Content()
#--> "123"

pf()
# Executed in 0.03 second(s)
