# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #373.

load "../../../stzBase.ring"


o1 = new stzString("{HELLO}")
o1.RemoveFromStart("{")
? o1.Content()
#--> "HELLO}"

o1.RemoveFromEnd("}")
? o1.Content()
#--> "HELLO"

pf()
# Executed in 0.01 second(s) in Ring 1.21
