# Narrative
# --------
# Getting current info #TODO
#
# Extracted from stzcalendartest.ring, block #18.

load "../../stzBase.ring"


pr()

oCal = new stzCalendar([2024, 10])
oCal {
	? Current()
	#--> October 2024	# Add the current day

	? @@(CurrentXT())
	#--> [ :year = ..., :month = ..., :day = ... ]

	? CurrentYear()

	? CurrentMonth() # for name and CurrentMonthN() for number

	? CurrentDay()

}

#NOTE: All dispaly of calendar should show the current day with a distinguuisded char

pf()
