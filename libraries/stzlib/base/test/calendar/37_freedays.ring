# Narrative
# --------
# #  FreeDays                      #
#
# Extracted from stzcalendartest.ring, block #37.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    # Getting the list of working days that aren't holidays"

    aFreeDays = FreeDays()

    ? "Free Days Count: " + len(aFreeDays) # Or use FreeDaysN()
    #--> Free Days Count: 23
    
    ? "First Free Day: " + aFreeDays[1]
    #--> First Free Day: 2024-10-01
}

pf()
# Executed in 0.09 second(s) in Ring 1.24
