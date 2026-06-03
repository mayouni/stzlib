# Narrative
# --------
# #  SetVizWidth and SetVizHeight  #
#
# Extracted from stzcalendartest.ring, block #48.

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    ? "Default Viz Width: " + VizWidth()
    #--> Default Viz Width: 50
    
    ? "Default Viz Height: " + VizHeight()
    #--> Default Viz Height: 10
    
    SetVizWidth(80)
    SetVizHeight(20)
    
    ? "After SetVizWidth(80): " + VizWidth()
    #--> After SetVizWidth(80): 80
    
    ? "After SetVizHeight(20): " + VizHeight()
    #--> After SetVizHeight(20): 20
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
