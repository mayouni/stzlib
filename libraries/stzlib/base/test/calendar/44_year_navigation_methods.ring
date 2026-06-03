# Narrative
# --------
# #  Year navigation methods       #
#
# Extracted from stzcalendartest.ring, block #44.

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    ? "Current: " + Current()
    #--> Current: October 2024
    
    ? "Previous Year: " + PreviousYear()
    #--> Previous Year: 2023
    
    ? "Current still: " + Current()
    #--> Current still: October 2024
    
    GoToPreviousYear()
    
    ? "After GoToPreviousYear: " + Current()
    #--> After GoToPreviousYear: October 2023
    
    ? nl + "Next Year: " + NextYear()
    #--> Next Year: 2024
    
    GoToNextYear()
    
    ? "After GoToNextYear: " + Current()
    #--> After GoToNextYear: October 2024
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
