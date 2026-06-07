# Narrative
# --------
# #  DetailedTable methods         #
#
# Extracted from stzcalendartest.ring, block #50.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Holiday")
    
    aDetailTable = DetailedTable()
    
    ? "Detailed Table Row Count: " + len(aDetailTable)
    #--> Detailed Table Row Count: 32 (header + 31 days)
    
    ? "First row: " + @@(aDetailTable[1])
    ? "Second row: " + @@(aDetailTable[2])
    
    ? nl + "===== Using DetailedTableQ ====="
    DetailedTableQ().Show()
}
#-->
'
Detailed Table Row Count: 32
First row: [ "Date", "Day", "Business", "Breaks", "Available" ]
Second row: [ "2024-10-01", "Tuesday", "09:00:00-17:00:00", "12:00:00-13:00:00", "7h" ]

╭────────────┬───────────┬───────────────────┬───────────────────┬───────────╮
│    Date    │    Day    │     Business      │      Breaks       │ Available │
├────────────┼───────────┼───────────────────┼───────────────────┼───────────┤
│ 2024-10-01 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-02 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-03 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-04 │ Friday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-05 │ Saturday  │ HOLIDAY           │                   │ 0h        │
│ 2024-10-06 │ Sunday    │ WEEKEND           │                   │ 0h        │
│ 2024-10-07 │ Monday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-08 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-09 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-10 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-11 │ Friday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-12 │ Saturday  │ WEEKEND           │                   │ 0h        │
│ 2024-10-13 │ Sunday    │ WEEKEND           │                   │ 0h        │
│ 2024-10-14 │ Monday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-15 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-16 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-17 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-18 │ Friday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-19 │ Saturday  │ WEEKEND           │                   │ 0h        │
│ 2024-10-20 │ Sunday    │ WEEKEND           │                   │ 0h        │
│ 2024-10-21 │ Monday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-22 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-23 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-24 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-25 │ Friday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-26 │ Saturday  │ WEEKEND           │                   │ 0h        │
│ 2024-10-27 │ Sunday    │ WEEKEND           │                   │ 0h        │
│ 2024-10-28 │ Monday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-29 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-30 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-31 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
╰────────────┴───────────┴───────────────────┴───────────────────┴───────────╯
'

pf()
# Executed in 0.58 second(s) in Ring 1.24
