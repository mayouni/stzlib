# Narrative
# --------
# TEST 9: Reuse object for multiple commands
#
# Extracted from stzsystemcalltest.ring, block #10.

load "../../stzBase.ring"


pr()


oCall = new stzSystemCall("cmd.exe")

# First command
oCall.SetArgs(["/c", "echo", "First"])
oCall.Run()
? oCall.Output()
#--> "First"

# Reset and second command
oCall.Reset()
oCall.SetArgs(["/c", "echo", "Second"])
oCall.Run()
? oCall.Output()
#--> "Second"

pf()
# Executed in 0.07 second(s) in Ring 1.24
