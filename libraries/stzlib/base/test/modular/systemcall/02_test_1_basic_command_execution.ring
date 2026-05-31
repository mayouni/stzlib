# Narrative
# --------
# TEST 1: Basic command execution
#
# Extracted from stzsystemcalltest.ring, block #2.

load "../../../stzBase.ring"


pr()

oCall = new stzSystemCall("cmd.exe")
oCall.SetArgs(["/c", "echo", "Hello World"])
oCall.Run()

? "Output: " + oCall.Output()
? "Exit code: " + oCall.ExitCode()
? "Success: " + oCall.Succeeded()

#--> Output: Hello World #TODO #ERR see why it returned \"Hello World\"
#    Exit code: 0
#    Success: 1

pf()
# Executed in 0.05 second(s) in Ring 1.24
