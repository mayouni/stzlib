# Narrative
# --------
# Hash
#
# Extracted from stzuuidtest.ring, block #5.

load "../../../stzBase.ring"


pr()

o1 = new stzUuid()
? o1.Hashed()
#--> 1484387222

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.35 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)
