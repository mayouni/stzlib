# Narrative
# --------
# TEST 15: Working with Sys() commands
#
# Extracted from stzsystemcalltest.ring, block #17.

load "../../stzBase.ring"


pr()

# Get current directory
oCall = new stzSystemCall(Sys(:CurrentDir))
oCall.Run()
? oCall.Output()
#-->
'D:\GitHub\stzlib\libraries\stzlib\base\test'

pf()
# Executed in 0.04 second(s) in Ring 1.24
