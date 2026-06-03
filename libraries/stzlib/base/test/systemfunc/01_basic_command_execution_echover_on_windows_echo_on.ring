# Narrative
# --------
# Basic command execution (echo/ver on Windows, echo on Unix)
#
# Extracted from stzsystemfunctest.ring, block #1.

load "../../stzBase.ring"


pr()

if isWindows()
	# Test with cmd.exe /c (Windows command processor)
	? stzsystem("cmd.exe", ["/c", "echo", "Hello from QProcess"])
else
	# Unix/Linux
	? stzsystem("echo", ["Hello from QProcess"])
ok
#--> "Hello from QProcess"

pf()
# Executed in 0.04 second(s) in Ring 1.24
