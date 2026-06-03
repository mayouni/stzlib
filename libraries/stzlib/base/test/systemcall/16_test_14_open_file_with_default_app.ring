# Narrative
# --------
# TEST 14: Open file with default app
#
# Extracted from stzsystemcalltest.ring, block #16.

load "../../stzBase.ring"


pr()

# Create a test file
write("systest/output.txt", "This file will be opened")

? "Opening systest/output.txt..."
StzSystemCallQ('').OpenFile("systest/output.txt")
? "✓ File opened with default application"

pf()
# Executed in 0.18 second(s) in Ring 1.24
