# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #70.

load "../../../stzBase.ring"


	o1 = new stzString("ruby ring php")
	o1.ReplaceAt(6, "ring", :By = "♥♥♥") # Or ReplaceSubStringAtPosition()

	? o1.Content()
	#--> "ruby ♥♥♥ php"

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.16 second(s) in Ring 1.17
