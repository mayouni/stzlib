# Narrative
# --------
# #  TotalWeeks and ContainsWeeks  #
#
# Extracted from stzcalendartest.ring, block #38.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    ? "Total Weeks: " + TotalWeeks()
    #--> Total Weeks: 5
    
    ? "Contains Weeks: " + ContainsWeeks()
    #--> Contains Weeks: TRUE
    
    ? "Has Weeks: " + HasWeeks()
    #--> Has Weeks: TRUE
    
    ? "Week Count aliases: " + WeeksN()
    #--> Week Count aliases: 5
}

pf()
# Executed in 0.02 second(s) in Ring 1.24
