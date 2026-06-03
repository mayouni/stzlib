# Narrative
# --------
# TEST 6: Success/failure checks
#
# Extracted from stzsystemcalltest.ring, block #7.

load "../../stzBase.ring"


pr()

# Successful command
oCall = new stzSystemCall("cmd.exe")
oCall.SetArgs(["/c", "echo", "test"])
oCall.Run()
? "Command 1 succeeded: " + oCall.Succeeded()

# Failed command
oCall.Reset()
oCall.SetArgs(["/c", "type", "badfile.txt"])
oCall.Run()
? "Command 2 failed: " + oCall.Failed()

#-->
'
Command 1 succeeded: 1
Command 2 failed: 1
'

pf()
# Executed in 0.07 second(s) in Ring 1.24
