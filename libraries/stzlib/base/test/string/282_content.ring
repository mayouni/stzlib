# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #282.

load "../../stzBase.ring"

pr()

o1 = new stzString("12345269775114")

o1.SpacifyXT(
	[ " ", ".", :LastChars = 6 ], [ 3, 2 ], :Backward
)

? o1.Content()
#--> 12 345 269.77 51 14

pf()
# Executed in 0.03 second(s).
