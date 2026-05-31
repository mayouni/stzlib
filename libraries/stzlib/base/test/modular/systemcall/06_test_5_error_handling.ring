# Narrative
# --------
# TEST 5: Error handling
#
# Extracted from stzsystemcalltest.ring, block #6.

load "../../../stzBase.ring"


pr()

o1 = StzSystemCallQ("cmd.exe")
o1.WithArgs(["/c", "type", "systest/nonexistent.txt"])
o1.Run()

if o1.Failed()
	? "✓ Correctly detected failure"
	? "  Exit code: " + o1.ExitCode()
	? "  Error: " + o1.Error()
ok

#-->
'
✓ Correctly detected failure
  Exit code: 1
  Error: The command syntax is incorrect.
'

pf()
# Executed in 0.05 second(s) in Ring 1.24
