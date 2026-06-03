# Narrative
# --------
# SETUP: Create test files in systest/
#
# Extracted from stzsystemcalltest.ring, block #1.

load "../../stzBase.ring"


pr()

# Ensure systest exists
if NOT isdir("systest")
	QMkdir("systest")
ok

# Create test files
write("systest/source.txt", "Hello from source file")
write("systest/data.txt", "Sample data for testing")
write("systest/test.txt", "Test content")

? "✓ Test files created in systest/"

pf()
# Executed in almost 0 second(s) in Ring 1.24
