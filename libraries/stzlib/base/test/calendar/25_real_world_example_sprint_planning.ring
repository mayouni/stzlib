# Narrative
# --------
# #  Real world example : sprint planning  #
#
# Extracted from stzcalendartest.ring, block #25.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])
oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
}

aTasks = [
    ["Design", 40],
    ["Development", 80],
    ["Testing", 32]
]

nRequired = 0
_nTasks1Len_ = ring_len(aTasks)
for _iLoopTasks1_ = 1 to _nTasks1Len_
	aTask = aTasks[_iLoopTasks1_]
    nRequired += aTask[2]
next

nAvailable = oCal.AvailableHoursN()

if nRequired <= nAvailable
    ? "✓ Sprint fits: " + nRequired + "h needed, " + nAvailable + "h available"
else
    ? "✗ Capacity exceeded by " + (nRequired - nAvailable) + " hours"
ok

#--> ✓ Sprint fits: 152h needed, 161h available

pf()
# Executed in 0.09 second(s) in Ring 1.24
