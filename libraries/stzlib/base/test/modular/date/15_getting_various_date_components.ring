# Narrative
# --------
# Getting various date components
#
# Extracted from stzdatetest.ring, block #15.

load "../../../stzBase.ring"


pr()

oDate = StzDateQ("15/07/2024")
oDate {

	? Year()
	#--> 2024

	? MonthNumber()
	#--> 7

	? DayNumber()
	#--> 15

	? DayOfWeek()
	#--> 1

	? DayOfYear()
	#--> 197

}

pf()
# Executed in almost 0 second(s) in Ring 1.23
