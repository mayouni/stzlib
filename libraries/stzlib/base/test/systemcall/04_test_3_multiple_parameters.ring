# Narrative
# --------
# TEST 3: Multiple parameters
#
# Extracted from stzsystemcalltest.ring, block #4.

load "../../stzBase.ring"


pr()

oCall = new stzSystemCall("cmd.exe")
oCall.SetArgs(["/c", "type", "{file}", "&", "echo.", "&", "type", "{file2}"])
oCall.SetParam(:file, "systest\source.txt")
oCall.SetParam(:file2, "systest\data.txt")
oCall.Run()

# Combined output
? oCall.Output()
#-->
'
Hello from source file 
Sample data for testing
'

pf()
# Executed in 0.05 second(s) in Ring 1.24
