# Narrative
# --------
# Navigation methods
#
# Extracted from stzdatetest.ring, block #32.

load "../../../stzBase.ring"


pr()

o1 = new stzDate("10/10/2025")

? o1.NextDay()
#--> 11/10/2025

? o1.PreviousDay()
#--> 09/10/2025

? o1.NextWeekday()
#--> 13/10/2025

? o1.PreviousWeekday()
#--> 09/10/2025

? o1.NextMonday()
#--> 13/10/2025

? o1.FirstDayOfMonth()
#--> 01/10/2025

? o1.LastDayOfMonth()
#--> 31/10/2025

? o1.StartOfMonth()
#--> 01/10/2025

? o1.EndOfMonth()
#--> 31/10/2025

? o1.StartOfYear()
#--> 01/01/2025

? o1.EndOfYear()
#--> 31/12/2025

? o1.DayAfterMonthEnd()
#--> 31/10/2025

? o1.DayBeforeMonthStart()
#--> 01/10/2025

? o1.DayAfterYearEnd()
#--> 31/12/2025

? o1.DayBeforeYearStart()
#--> 01/01/2025

? o1.NextEndOfMonth()
#--> 31/10/2025

? o1.PreviousEndOfMonth()
#--> 31/10/2025

? o1.NextStartOfMonth()
#--> 01/10/2025

? o1.PreviousStartOfMonth()
#--> 01/10/2025

? o1.MidMonth()
#--> 16/10/2025

? o1.FirstWeekdayOfMonth()
#--> 01/10/2025

? o1.LastWeekdayOfMonth()
#--> 31/10/2025

pf()
# Executed in 0.02 second(s) in Ring 1.24
