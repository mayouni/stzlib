# Narrative
# --------
# #  Available days list           #
#
# Extracted from stzcalendartest.ring, block #35.

load "../../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    aAvailableDays = AvailableDays()
    
    ? "Available Days Count: " + len(aAvailableDays)
    #--> Available Days Count: 22
    
    ? "Contains Available Days: " + ContainsAvailableDays()
    #--> Contains Available Days: 1
    
    ? "Has Available Days: " + HasAvailableDays()
    #--> Has Available Days: 1
    
    ? @@NL(aAvailableDays)
    # Shows list of all available working days excluding holidays
}
#-->
'
[
	"2024-10-01", #TODO// See why this format is different
	"02/10/2024",
	"03/10/2024",
	"04/10/2024",
	"07/10/2024",
	"08/10/2024",
	"09/10/2024",
	"10/10/2024",
	"11/10/2024",
	"14/10/2024",
	"15/10/2024",
	"16/10/2024",
	"17/10/2024",
	"18/10/2024",
	"21/10/2024",
	"22/10/2024",
	"23/10/2024",
	"24/10/2024",
	"25/10/2024",
	"28/10/2024",
	"29/10/2024",
	"30/10/2024",
	"31/10/2024"
]
'

pf()
# Executed in 0.28 second(s) in Ring 1.24
