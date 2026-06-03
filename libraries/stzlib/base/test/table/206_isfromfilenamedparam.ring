# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #206.
#ERR Error (R14) : Calling Method without definition: isfromfilenamedparam

load "../../stzBase.ring"

pr()

? Q(:FromFile = "mytable.csv").IsFromFileNamedParam()

pf()
# Executed in 0.02 second(s)
