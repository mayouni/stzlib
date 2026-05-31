# Narrative
# --------
# #  List initialization variants           #
#
# Extracted from stzcalendartest.ring, block #30.

load "../../../stzBase.ring"

#-----------------------------------------#

pr()

# Test [year, month] format
oCal1 = new stzCalendar([2024, 10])

oCal1 {
    ? "Format [year, month] - Start: " + Start()
    #--> Format [year, month] - Start: 2024-10-01
}

? nl

# Test [year, "Q3"] format
oCal2 = new stzCalendar([2024, "Q3"])

oCal2 {
    ? "Format [year, Q] - Start: " + Start()
    #--> Format [year, Q] - Start: 2024-07-01
    
    ? "Format [year, Q] - End: " + End_()
    #--> Format [year, Q] - End: 2024-09-30
}

? nl

# Test named parameters
oCal3 = new stzCalendar([ :Start = "2024-10-01", :End = "2024-10-31" ])

oCal3 {
    ? "Named params - Start: " + Start()
    #--> Named params - Start: 2024-10-01
    
    ? "Named params - End: " + End_()
    #--> Named params - End: 2024-10-31
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
