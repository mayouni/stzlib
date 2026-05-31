# Narrative
# --------
# #  IsToday method                #
#
# Extracted from stzcalendartest.ring, block #40.

load "../../../stzBase.ring"

#--------------------------------#

pr()

# Create calendar for current month
oCal = new stzCalendar([2024, 10])

oCal {
    ? "Is Today (October 2024): " + IsToday()
    #--> FALSE (Result depends on current date)
}


# Create a single-day calendar for today

oTodayCal = new stzCalendar(Today())
	? "Single day calendar is today: " + oTodayCal.IsToday()
	#--> TRUE
}

pf()
# Executed in 0.03 second(s) in Ring 1.24
