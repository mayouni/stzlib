# Narrative
# --------
# Null Uuid
#
# Extracted from stzuuidtest.ring, block #4.

load "../../stzBase.ring"


pr()

? NullUuid()
#--> 00000000-0000-0000-0000-000000000000

? ""
o1 = new stzUuid()

? o1.IsNull()
#--> FALSE

? o1.Content()
#--> 3D7543C0-E5B4-43B2-B3D6-75A2AF5131D4

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.36 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)
