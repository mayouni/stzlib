# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #205.
#ERR Error (R14) : Calling Method without definition: isapairq

load "../../stzBase.ring"

pr()

o1 = new stzList([ :StartingAt, 5 ])
? o1.IsAPairQ().Where('{ isString(@pair[1]) and isNumber(@pair[2]) }')

pf()
# Executed in 0.06 second(s) in Ring 1.21
