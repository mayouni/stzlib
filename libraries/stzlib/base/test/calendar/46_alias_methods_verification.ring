# Narrative
# --------
# #  Alias methods verification    #
#
# Extracted from stzcalendartest.ring, block #46.

load "../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    # Test various alias forms
    ? "TotalDays: " + TotalDays()
    ? "DaysN: " + DaysN()
    ? "NumberOfDays: " + NumberOfDays()
    ? "HowManyDays: " + HowManyDays()
    ? "CountDays: " + CountDays()
    
    ? nl + "AvailableDaysN: " + AvailableDaysN()
    ? "HowManyAvailableDays: " + HowManyAvailableDays()
    ? "CountAvailableDays: " + CountAvailableDays()
    
    ? nl + "HolidaysN: " + HolidaysN()
    ? "NumberOfHolidays: " + NumberOfHolidays()
    ? "CountHolidays: " + CountHolidays()
    
    ? nl + "AvailableHoursN: " + AvailableHoursN()
    ? "HowManyAvailableHoursB: " + HowManyAvailableHoursB()
    ? "CountAvailableHours: " + CountAvailableHours()
}

pf()
# Executed in 0.43 second(s) in Ring 1.24
