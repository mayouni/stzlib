# Narrative
# --------
# #  Test 5: Capacity calculations          #
#
# Extracted from stzcalendartest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    ? AvailableHoursN()
    #--> 161

    ? AvailableDaysN()
    #--> 23

    ? AvailableHoursOnN("2024-10-10")
    #--> 7

    ? AvailableHoursBetweenN("2024-10-01", "2024-10-15")
    #--> 77

}

pf()
# Executed in 0.20 second(s) in Ring 1.24
