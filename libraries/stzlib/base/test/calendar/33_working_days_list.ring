# Narrative
# --------
# #  Working days list             #
#
# Extracted from stzcalendartest.ring, block #33.

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    
    aWorkingDays = WorkingDays()
    
    ? "Number of working days: " + len(aWorkingDays)
    #--> Number of working days: 23
    
    ? "First working day: " + aWorkingDays[1]
    #--> First working day: 2024-10-01
    
    ? "Last working day: " + aWorkingDays[len(aWorkingDays)]
    #--> Last working day: 2024-10-31
}

pf()
# Executed in 0.10 second(s) in Ring 1.24
