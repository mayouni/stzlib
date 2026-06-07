# Narrative
# --------
# #  Test 3: Holiday management             #
#
# Extracted from stzcalendartest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    AddHoliday("2024-10-05", "Independence Day")
    AddHoliday("2024-10-15", "National Day")
    
    ? IsHoliday("2024-10-05")
    #--> 1
    
    ? HolidayName("2024-10-05")
    #--> Independence Day
    
    ? len(Holidays())
    #--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
