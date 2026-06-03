# Narrative
# --------
# #  Single date initialization             #
#
# Extracted from stzcalendartest.ring, block #28.

load "../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar("2024-10-15")

oCal {
    ? "Start: " + Start()
    #--> Start: 2024-10-15
    
    ? "End: " + End_()
    #--> End: 2024-10-15
    
    ? "Total Days: " + TotalDays()
    #--> Total Days: 1
    
    ? "Contains Days: " + ContainsDays()
    #--> Contains Days: 1
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
