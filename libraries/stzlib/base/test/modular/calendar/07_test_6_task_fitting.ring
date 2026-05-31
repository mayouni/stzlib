# Narrative
# --------
# #  Test 6: Task fitting                   #
#
# Extracted from stzcalendartest.ring, block #7.

load "../../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? CanFit("2024-10-10", "5")
    #--> TRUE

    ? CanFit("2024-10-10", "10")
    #--> FALSE

    ? @@NL( FirstAvailableSlot("4") )
    #--> [ "2024-10-01 09:00:00", "2024-10-01 04:00:00" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
