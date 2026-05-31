# Narrative
# --------
# TEST 10: Step-by-step building
#
# Extracted from stzsystemcalltest.ring, block #11.

load "../../../stzBase.ring"


pr()

oCall = new stzSystemCall("cmd.exe")
oCall {
	AddArg("/c")
	AddArg("echo")
	AddArg("Step")
	AddArg("by")
	AddArg("step")

	HideConsole()
	Run()

	? Output()
}
#--> Step by step

pf()
# Executed in 0.04 second(s) in Ring 1.24
