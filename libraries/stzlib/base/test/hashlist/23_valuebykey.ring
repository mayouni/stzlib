# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #23.

load "../../stzBase.ring"

pr()

o1 = new stzHashList([ :math = 18, :stats = 16, :history = 14 ])

? o1.ValueByKey(:stats)
#--> 16

? o1[:stats]
#--> 16

pf()
# Executed in 0.04 second(s)
