# Narrative
# --------
# #  Test 9: Heat map visualization         #
#
# Extracted from stzcalendartest.ring, block #10.

load "../../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Independence Day")
    
    ShowHeatMap()
}
#-->
'
October 2024 - Capacity Heat Map

Week 1:  ▓▓▓▓▓ (5/5 days available)
Week 2:  ▓▓▓▓▓ (5/5 days available)
Week 3:  ▓▓▓▓▓ (5/5 days available)
Week 4:  ▓▓▓▓▓ (5/5 days available)
Week 5:  ▓▓▓░░ (3/5 days available)

Legend:
  ▓ = Available working day
  ░ = Weekend or holiday
'

pf()
# Executed in 0.03 second(s) in Ring 1.24
