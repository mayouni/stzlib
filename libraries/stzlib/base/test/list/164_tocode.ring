# Narrative
# --------
# Shows how ToCode() serializes a stzList back into the literal Ring
# source string you would type to recreate it.
#
# ToCode() round-trips a value into code: each string is quoted with a
# delimiter that keeps its own embedded quotes intact (a string holding
# a double quote is wrapped in single quotes and vice versa), nested
# lists are emitted recursively with their own brackets, and numbers are
# left unquoted. The result is a faithful, paste-able [ ... ] literal --
# the inverse of evaluating code into a list.
#
# Extracted from stzlisttest.ring, block #164.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"*", '"*"', "*4", [ "A", "B" , "'C'"], 12
])

? o1.ToCode()
#--> [ "*", '"*"', "*4", [ "A", "B", "'C'" ], 12 ]

pf()
# Executed in 0.04 second(s)
