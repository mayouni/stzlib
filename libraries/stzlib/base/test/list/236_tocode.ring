# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #236.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 10, '"[ :Tunis, :Paris ]"', "ONE," ])
? o1.ToCode()
#-- [ 10, '"[ :Tunis, :Paris ]"', "ONE," ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in ring 1.17
