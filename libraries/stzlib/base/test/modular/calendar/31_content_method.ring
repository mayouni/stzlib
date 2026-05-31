# Narrative
# --------
# #  Content method                         #
#
# Extracted from stzcalendartest.ring, block #31.

load "../../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddHoliday("2024-10-05", "Holiday")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? @@NL(Content())
    #-->
    '
    [
        [ "start", "2024-10-01" ],
        [ "end", "2024-10-31" ],
        [ "year", 2024 ],
        [ "month", 10 ],
        [ "quarter", "" ],
        [ "totaldays", 31 ],
        [ "workingdays", 23 ],
        [ "holidays", [ [ "2024-10-05", "Holiday" ] ] ],
        [ "businesshours", [ [ "from", "09:00:00" ], [ "to", "17:00:00" ] ] ],
        [ "breaks", [ [ "12:00:00", "13:00:00", "Lunch" ] ] ]
    ]
    '
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
