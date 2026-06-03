# Narrative
# --------
# #  Month navigation methods      #
#
# Extracted from stzcalendartest.ring, block #45.

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    ? "Current: " + Current()
    #--> Current: October 2024
    
    ? "Next Month: " + NextMonth()
    #--> Next Month: November
    
    ? "Current still: " + Current()
    #--> Current still: October 2024
    
    GotoNextMonth()
    
    ? "After GotoNextMonth: " + Current()
    #--> After GotoNextMonth: November 2024
    
    ? nl + "Previous Month: " + PreviousMonth()
    #--> Previous Month: October
    
    GoToPreviousMonth()
    
    ? "After GoToPreviousMonth: " + Current()
    #--> After GoToPreviousMonth: October 2024
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
