# Narrative
# --------
# TEST 7: Output capture control
#
# Extracted from stzsystemcalltest.ring, block #8.

load "../../stzBase.ring"


pr()

# Capture only errors
o1 = StzSystemCallQ("cmd.exe")
o1 {
	WithArgs(["/c", "type", "systest/nonexistent.txt"])

	DontCaptureOutput()
	CaptureError()

	Run()
}

? o1.HasOutput()
#--> FALSE

? o1.HasError()
#--> TRUE

? o1.Error()
#--> The command syntax is incorrect.

pf()
# Executed in 0.04 second(s) in Ring 1.24
