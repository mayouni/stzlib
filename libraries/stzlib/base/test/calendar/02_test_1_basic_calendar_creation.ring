# Narrative
# --------
# #  Test 1: Basic calendar creation        #
#
# Extracted from stzcalendartest.ring, block #2.

load "../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {

    ? Start()
    #--> 2024-10-01
    ? StartQ().DayName()
    #--> Tuesday

    ? End_()
    #--> 2024-10-31
    ? EndQ().DayName()
    #--> Thursday

    ? Year()
    #--> 2024
    
    ? MonthName()
    #--> October
    
    ? TotalDays()
    #--> 31
}

pf()
# Executed in almost 0 second(s) in Ring 1.26
# Executed in almost 0 second(s) in Ring 1.24
