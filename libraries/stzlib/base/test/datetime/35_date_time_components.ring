# Narrative
# --------
# Date time components
#
# Extracted from stzdatetimetest.ring, block #35.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:30:18.750")
oDateTime {

	? Year()	 #--> 2024

	? Month()	 #--> March
	? MonthN()	 #--> 3

	? Day()		 #--> Friday
	? DayN()	 #--> 15

	? Hours()	 #--> 10
	? Minutes()	 #--> 30
	? Seconds()	 #--> 18
	? Milliseconds() #--> 750

}

pf()
# Executed in 0.01 second(s) in Ring 1.23
