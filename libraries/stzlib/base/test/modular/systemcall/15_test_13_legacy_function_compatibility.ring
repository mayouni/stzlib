# Narrative
# --------
# TEST 13: Legacy function compatibility
#
# Extracted from stzsystemcalltest.ring, block #15.

load "../../../stzBase.ring"


pr()

# Using stzsystemXT()
cOutput = stzsystemXT("cmd.exe", ["/c", "echo", "Legacy call"])
? "stzsystem(): " + cOutput

# Using stzsystemSilent()
stzsystemSilentXT("cmd.exe", ["/c", "echo", "Silent legacy"])
? "✓ stzsystemSilent() executed (no output)"

pf()
# Executed in 0.07 second(s) in Ring 1.24
