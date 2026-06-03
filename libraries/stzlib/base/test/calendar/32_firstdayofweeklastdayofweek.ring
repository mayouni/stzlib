# Narrative
# --------
# #  FirstDayOfWeek/LastDayOfWeek           #
#
# Extracted from stzcalendartest.ring, block #32.

load "../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    
    ? "First Day of Week: " + FirstDayOfWeek()
    #--> First Day of Week: 2024-09-30 (Monday of week containing 2024-10-01)
    
    ? "Last Day of Week: " + LastDayOfWeek()
    #--> Last Day of Week: 2024-10-06 (Sunday)
}

pf()
# Executed in 0.03 second(s) in Ring 1.24
