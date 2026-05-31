# Narrative
# --------
# #  Weekends list                 #
#
# Extracted from stzcalendartest.ring, block #34.

load "../../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    
    aWeekends = Weekends()
    
    ? "Number of weekend days: " + WeekendsN()
    #--> Number of weekend days: 8
    
    ? "First weekend day: " + aWeekends[1]
    #--> First weekend day: 2024-10-05
    
    ? "Contains Weekends: " + ContainsWeekends()
    #--> Contains Weekends: TRUE
    
    ? "Has Weekends: " + HasWeekends()
    #--> Has Weekends: TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
