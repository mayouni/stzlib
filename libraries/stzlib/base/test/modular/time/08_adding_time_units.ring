# Narrative
# --------
# Adding time units
#
# Extracted from stztimetest.ring, block #8.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("10:00:00")
oTime {

	AddSeconds(30)
	? Content()
	#--> 10:00:30

	AddMinutes(15)
	? Content()
	#--> 10:15:30

	oTime.AddHours(2)
	? Content()
	#--> 12:15:30
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
