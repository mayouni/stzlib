# Narrative
# --------
# #  Test 2: Working days configuration     #
#
# Extracted from stzcalendartest.ring, block #3.

load "../../../stzBase.ring"

#-----------------------------------------#
pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    
    ? IsWorkingDay("2024-10-03")
    #--> 1
    
    ? IsWorkingDay("2024-10-05")
    #--> 0
    
    ? FirstWorkingDay()
    #--> 2024-10-01
    
    ? len(WorkingDays())
    #--> 23
}

pf()
# Executed in 0.07 second(s) in Ring 1.24
