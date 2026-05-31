# Narrative
# --------
# Subtracting time units
#
# Extracted from stztimetest.ring, block #9.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("12:30:45")
oTime {

	SubtractSeconds(45)
	? Content()
	#--> 12:30:00

	SubtractMinutes(30)
	? Content()
	#--> 12:00:00

	SubtractHours(2)
	? Content()
	#--> 10:00:00
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
