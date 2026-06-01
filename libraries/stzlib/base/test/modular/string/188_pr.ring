# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #188.

load "../../../stzBase.ring"


Q("♥♥♥ Ring programing language ♥♥♥") {

	ReplaceXT( :Each = "♥", [], :With = "*")
	? Content()
	#--> *** Ring programing language ***

	ReplaceXT("*", :With = "♥", [])
	? Content()
	#--> ♥♥♥ Ring programing language ♥♥♥
}

pf()
# Executed in 0.02 second(s) in Ring 1.21s
# Executed in 0.05 second(s) in Ring 1.20
