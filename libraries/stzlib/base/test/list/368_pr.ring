# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #368.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ONE", "TWO", "THREE" ])
? o1 - "TWO"
#--> [ "ONE", "THREE" ]

pf()
# Executed in almost 0 second(s).
