# Narrative
# --------
# #  Year-month string init                 #
#
# Extracted from stzcalendartest.ring, block #27.

load "../../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar("2024-10")

oCal {
    ? "Start: " + Start()
    #--> Start: 2024-10-01
    
    ? "End: " + End_()
    #--> End: 2024-10-31
    
    ? "Month Name: " + MonthName()
    #--> Month Name: October
    
    ? "Month Number: " + MonthNumber()
    #--> Month Number: 10
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
