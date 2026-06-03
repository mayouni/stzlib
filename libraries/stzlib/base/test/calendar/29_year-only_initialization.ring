# Narrative
# --------
# #  Year-only initialization               #
#
# Extracted from stzcalendartest.ring, block #29.

load "../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar(2024)

oCal {
    ? "Start: " + Start()
    #--> Start: 2024-01-01
    
    ? "End: " + End_()
    #--> End: 2024-12-31
    
    ? "Year: " + Year()
    #--> Year: 2024
    
    ? "Total Days: " + TotalDays()
    #--> Total Days: 366 (leap year)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
