# Narrative
# --------
# #  Quarter initialization                 #
#
# Extracted from stzcalendartest.ring, block #26.

load "../../stzBase.ring"

#-----------------------------------------#

pr()

# Test Q1
oCal_Q1 = new stzCalendar("2024-Q1")

oCal_Q1 {
    ? Start()
    #--> 2024-01-01
    
    ? End_()
    #--> 2024-03-31
    
    ? QuarterNumber()
    #--> 1
    
    ? TotalDays()
    #--> 91
}

? nl

# Test Q2
oCal_Q2 = new stzCalendar("2024-Q2")

oCal_Q2 {
    ? Start()
    #--> 2024-04-01
    
    ? End_()
    #--> 2024-06-30
    
    ? TotalDays()
    #--> 91
}

? nl

# Test Q3
oCal_Q3 = new stzCalendar("2024-Q3")

oCal_Q3 {
    ? Start()
    #--> 2024-07-01
    
    ? End_()
    #--> 2024-09-30
}

? nl

# Test Q4
oCal_Q4 = new stzCalendar("2024-Q4")

oCal_Q4 {
    ? Start()
    #--> 2024-10-01
    
    ? End_()
    #--> 2024-12-31
}

pf()
# Executed in 0.03 second(s) in Ring 1.24
