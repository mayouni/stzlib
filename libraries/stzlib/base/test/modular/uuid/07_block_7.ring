# Narrative
# --------
#
# Extracted from stzuuidtest.ring, block #7.

load "../../../stzBase.ring"

pr()

o1 = new stzString("Ring")
? o1.HasUuid()
#--> FALSE

o1.SetUuid()
? o1.Uuid()
#--> "E1C2A3B4-D74E-459E-99CE-1380D59B6DEC"

? o1.HashedUuid()
#--> "1944623326"

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.37 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)
