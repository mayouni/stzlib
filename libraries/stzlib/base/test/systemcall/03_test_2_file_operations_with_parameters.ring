# Narrative
# --------
# TEST 2: File operations with parameters
#
# Extracted from stzsystemcalltest.ring, block #3.

load "../../stzBase.ring"


pr()

oCall = new stzSystemCall(Sys(:CopyFile))
oCall.SetParam(:source, "systest/source.txt")
oCall.SetParam(:dest, "systest/backup.txt")
oCall.Run()

if oCall.Succeeded()
	? "✓ File copied successfully"
	? "  Check: " + fexists("systest/backup.txt")
else
	? "✗ Copy failed: " + oCall.Error()
ok

pf()
# Executed in 0.05 second(s) in Ring 1.24
