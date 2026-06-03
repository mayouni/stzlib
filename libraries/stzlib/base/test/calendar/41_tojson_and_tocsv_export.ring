# Narrative
# --------
# #  ToJSON and ToCSV export       #
#
# Extracted from stzcalendartest.ring, block #41.

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    SetBusinessHours("09:00:00", "17:00:00")
    
    # Test JSON export
    cJSON = ToJSON()
    ? RoundBox("JSON Export (first 100 chars)")
    ? @substr(cJSON, 1, 100) + NL
    
    # Test CSV export
    cCSV = ToCSV() # Or ToCSVXT(";") if you want to specify a separator
    ? RoundBox("CSV Export (first 200 chars)")
    ? @substr(cCSV, 1, 200)
}
#--> #TODO Check the correctness of JSON string
#--> #TODO Check why Quarter is null in CSV string
'
╭───────────────────────────────╮
│ JSON Export (first 100 chars) │
╰───────────────────────────────╯
[][],
"businessstart": "09:00:00",
"businessend": "17:00:00"
}

╭──────────────────────────────╮
│ CSV Export (first 200 chars) │
╰──────────────────────────────╯
Metric,Value
Start Date;2024-10-01
End Date;2024-10-31
Year;2024
Month;10
Quarter;
Total Days;31
Working Days;23
Available Hours;184
Business Start;09:00:00
Business End;17:00:00
Holiday;2024-10-05;Ho
'

pf()
# Executed in almost 0.27 second(s) in Ring 1.24
