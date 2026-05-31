# Narrative
# --------
# TEST 8: Silent execution
#
# Extracted from stzsystemcalltest.ring, block #9.

load "../../../stzBase.ring"


pr()

# This command will run silently : no output returned

StzSystemCallQ("cmd.exe").
	WithArgsQ(["/c", "echo", "This runs silently"]).
	RunSilently()

pf()
# Executed in 0.03 second(s) in Ring 1.24
