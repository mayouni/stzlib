# Narrative
# --------
# Command with output capture
#
# Extracted from stzsystemfunctest.ring, block #2.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

if isWindows()
	? stzsystem("cmd.exe", ["/c", "echo", "Test output"])
else
	?stzsystemOutput("echo", ["Test output"])
ok
#--> "Test output"

pf()
# Executed in 0.06 second(s) in Ring 1.24
