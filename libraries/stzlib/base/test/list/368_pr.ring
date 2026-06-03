# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #368.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ONE", "TWO", "THREE" ])
? o1 - "TWO"
#--> [ "ONE", "THREE" ]

pf()
# Executed in almost 0 second(s).
