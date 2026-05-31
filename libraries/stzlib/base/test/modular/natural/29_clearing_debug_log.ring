# Narrative
# --------
# CLEARING DEBUG LOG
#
# Extracted from stznaturaltest.ring, block #29.

load "../../../stzBase.ring"


pr()

Nt = Naturally("")
Nt.EnableDebug()
Nt.Execute("Create string with 'test'")

? "Before clear: " + len(Nt.DebugLog())
? len(Nt.DebugLog()) #--> 19

Nt.ClearDebugLog()
? "After clear: " + len(Nt.DebugLog())
? len(Nt.DebugLog()) #--> 0

pf()
# Executed in 0.01 second(s) in Ring 1.24
