# Narrative
# --------
# #  AvailableWeeks and Minutes    #
#
# Extracted from stzcalendartest.ring, block #39.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? "Available Weeks: " + AvailableWeeksN()
    #--> Available Weeks: 5 (ceil(23 / 5))
    
    ? "Contains Available Weeks: " + ContainsAvailableWeeks()
    #--> Contains Available Weeks: TRUE
    
    ? "Available Minutes: " + AvailableMinutesN()
    #--> Available Minutes: 9660
    
    ? "Alternative form: " + AvailableMinutes()
    #--> Alternative form: 9660
}

pf()
# Executed in 0.31 second(s) in Ring 1.24
