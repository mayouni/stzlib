# Narrative
# --------
# TEST 17: Chaining with Q methods
#
# Extracted from stzsystemcalltest.ring, block #21.

load "../../stzBase.ring"


pr()

oCall = StzSystemCallQ("cmd.exe").
	WithArgsQ(["/c", "echo", "Chained"]).
	SetTimeoutQ(3000).
	HideConsoleQ().
	RunQ()

? oCall.Output() #--> "Chained"

? oCall.Timeout() #--> 3000

pf()
#--> Executed in 0.04 second(s) in Ring 1.24
