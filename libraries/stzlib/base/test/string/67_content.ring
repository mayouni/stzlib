# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #67.

load "../../stzBase.ring"

pr()

	o1 = new stzString("ring ♥♥♥ruby php")
	o1.RemoveXT("♥♥♥", :AtPosition = 6)

	? o1.Content()
	#--> "ring ruby php"

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.18
