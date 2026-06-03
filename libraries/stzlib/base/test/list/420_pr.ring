# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #420.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzString("A**BC***DE***")
? o1 - "*"
#--> ABCDE

# Note that o1 content did not change:

? o1.Content()
#--> A**BC***DE***

pf()
# Executed in 0.01 second(s).
