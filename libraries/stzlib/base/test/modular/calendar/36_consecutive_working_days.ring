# Narrative
# --------
# #  Consecutive working days      #
#
# Extracted from stzcalendartest.ring, block #36.

load "../../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    aConsecutive = ConsecutiveWorkingDaysAvailable("2024-10-01")
    
    ? "Consecutive working days from Oct 1: " + len(aConsecutive)
    #--> Consecutive working days from Oct 1: 4
    
    ? "Alternative form: " + ConsecutiveAvailableWorkingDaysN("2024-10-01")
    #--> Alternative form: 4
    
    ? "Starting from Oct 7: " + ConsecutiveWorkingDaysAvailableN("2024-10-07")
    #--> Starting from Oct 7: 5
}

pf()
# Executed in 0.06 second(s) in Ring 1.24
