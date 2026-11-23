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
# CAPTURED FROM A RUN, NOT AUTHORED. The promise below is a REGRESSION
# BASELINE taken on haro 21317660327e7241, engine stzlib c2b930b71,
# 2026-11-23. The arrow was left empty by whoever wrote this file, so nobody
# has ever judged the value: it records what the code DOES, not what it
# SHOULD do. If it and the code disagree later, read BOTH -- the promise may
# be the defect. (That is how 192 came to be promised for a draw from a list
# not containing it; see listofnumbers/36_anynumberbefore.ring.)
? oCall.Output()
#--> Hello from source file
'
Hello from source file 
Sample data for testing
'

pf()
# Executed in 0.05 second(s) in Ring 1.24
