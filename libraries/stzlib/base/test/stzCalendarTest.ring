load "../stzbase.ring"

#------------------------------------------#
#  Basic Calendar Creation with Periods    #
#------------------------------------------#

/*--- Creating calendar with year and month

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	? Start()
	#--> 2024-10-01

	? End_()
	#--> 2024-10-31

	? Year()
	#--> 2024

	? MonthNumber()
	#--> 10

	? MonthName()
	#--> October

	? TotalDays()
	#--> 31

	? TotalWeeks()
	#--> 5

	? Current()
	#--> October 2024
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Creating calendar with year only (full year view)

pr()

oCal = new stzCalendar(2024)

oCal {
	? Start()
	#--> 2024-01-01

	? End_()
	#--> 2024-12-31

	? TotalDays()
	#--> 366

	? TotalWeeks()
	#--> 53
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Creating calendar with quarter

pr()

oCal = new stzCalendar([2024, "Q3"])

oCal {
	? Start()
	#--> 2024-07-01

	? End_()
	#--> 2024-09-30

	? QuarterNumber()
	#--> 3

	? Current()
	#--> Q3 2024
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Creating calendar with date range

pr()

oCal = new stzCalendar([ :Start = "2024-10-01", :End = "2024-10-31" ])

oCal {
	? Start()
	#--> 2024-10-01

	? End_()
	#--> 2024-10-31

	? NumberOfDays() # Or DaysN()
	#--> 31
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Creating calendar with named parameters

pr()

oCal = new stzCalendar([ :Start = "2024-10-01", :End = "2024-12-31" ])

oCal {
	? Start()
	#--> 2024-10-01

	? End_()
	#--> 2024-12-31

	? DaysN()
	#--> 92
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

#------------------------------------------#
#  Working Days Configuration              #
#------------------------------------------#

/*--- Setting and querying working days

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])

	? IsWorkingDay("2024-10-03")
	#--> 1

	? IsWorkingDay("2024-10-05")
	#--> 0

	? FirstWorkingDay()
	#--> 2024-10-01

	? LastWorkingDay()
	#--> 2024-10-31

	? len( WorkingDays() )
	#--> 23
}

pf()
# Executed in 0.08 second(s) in Ring 1.24

/*--- Querying weekend days

pr()

oCal = new stzCalendar([2024, 10])
oCal.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])

aWeekends = oCal.Weekends()

? len(aWeekends)
#--> 8

? aWeekends[1]
#--> 05/10/2024

pf()
# Executed in 0.03 second(s) in Ring 1.24

#------------------------------------------#
#  Holiday Management                      #
#------------------------------------------#

/*--- Adding and checking holidays

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	AddHoliday("2024-10-05", "Independence Day")
	AddHoliday("2024-10-15", "National Day")

	? IsHoliday("2024-10-05")
	#--> 1

	? IsHoliday("2024-10-10")
	#--> 0

	? HolidayName("2024-10-05")
	#--> Independence Day

	aHolidays = Holidays()
	? len(aHolidays)
	#--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Finding holidays in date range

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	AddHoliday("2024-10-05", "Independence Day")
	AddHoliday("2024-10-25", "Revolution Day")

	aHolidaysInRange = HolidaysBetween("2024-10-01", "2024-10-20")

	? len(aHolidaysInRange)
	#--> 1

	? aHolidaysInRange[1][2]
	#--> Independence Day
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#------------------------------------------#
#  Business Hours and Breaks               #
#------------------------------------------#

/*--- Setting business hours and breaks

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetBusinessHours("09:00:00", "17:00:00")

	aBusinessHours = BusinessHours()
	? aBusinessHours[1][2]
	#--> 09:00:00

	? aBusinessHours[2][2]
	#--> 17:00:00

	AddBreak("12:00:00", "13:00:00", "Lunch")
	AddBreak("15:00:00", "15:15:00", "Break")

	aBreaks = Breaks()
	? len(aBreaks)
	#--> 2
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#------------------------------------------#
#  Capacity Calculations                   #
#------------------------------------------#

/*--- Calculating available hours in working month

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
	SetBusinessHours("09:00:00", "17:00:00")

	AddBreak("12:00:00", "13:00:00", "Lunch")
	AddHoliday("2024-10-05", "Independence Day")

	? AvailableHours()
	#--> 161

	? AvailableDays()
	#--> 23

	? AvailableMinutes()
	#--> 9660
}

pf()
# Executed in 0.24 second(s) in Ring 1.24

/*--- Calculating available hours on specific date

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
	SetBusinessHours("09:00:00", "17:00:00")
	AddBreak("12:00:00", "13:00:00", "Lunch")

	? AvailableHoursOn("2024-10-03")
	#--> 7

	? AvailableHoursOn("2024-10-05")
	#--> 0
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Calculating hours in date range

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
	SetBusinessHours("09:00:00", "17:00:00")
	AddBreak("12:00:00", "13:00:00", "Lunch")

	? AvailableHoursBetween("2024-10-01", "2024-10-15")
	#--> 77
}

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*--- Checking if duration fits and consecutive working days
*/
pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
	AddHoliday("2024-10-13", "Holiday")

	? CanFit("2024-10-10", "8")
	#--> 1

	? CanFit("2024-10-10", "10")
	#--> 0

	? ConsecutiveWorkingDaysAvailable("2024-10-10")
	#--> 2
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Finding first available slot for a task

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
	SetBusinessHours("09:00:00", "17:00:00")
	AddBreak("12:00:00", "13:00:00", "Lunch")

	aSlot = FirstAvailableSlot("4")

	? aSlot[1]
	#--> 2024-10-01 09:00:00

	? aSlot[2]
	#--> 2024-10-01 13:00:00
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#------------------------------------------#
#  Navigation and Current State            #
#------------------------------------------#

/*--- Navigating between months

pr()

oCal = new stzCalendar([2024, 10])

? oCal.Current()
#--> October 2024

oCal.NextMonth()

? oCal.Current()
#--> November 2024

oCal.PreviousMonth()

? oCal.Current()
#--> October 2024

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Navigating between years

pr()

oCal = new stzCalendar([2024, 10])

? oCal.Year()
#--> 2024

oCal.NextYear()

? oCal.Year()
#--> 2025

oCal.PreviousYear()

? oCal.Year()
#--> 2024

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Checking if today is in calendar range

pr()

oCal = new stzCalendar([2024, 10])

? oCal.IsToday()
#--> 0

pf()
# Executed in 0.01 second(s) in Ring 1.24

#------------------------------------------#
#  Date Information and Queries            #
#------------------------------------------#

/*--- Getting information about specific date

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
	SetBusinessHours("09:00:00", "17:00:00")
	AddBreak("12:00:00", "13:00:00", "Lunch")
	AddHoliday("2024-10-05", "Independence Day")

	aInfo = DateInfo("2024-10-03")

	? aInfo[1][2]
	#--> 2024-10-03

	? aInfo[2][2]
	#--> 1

	? aInfo[3][2]
	#--> 0

	? aInfo[4][2]
	#--> 8
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Getting calendar statistics

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
	SetBusinessHours("09:00:00", "17:00:00")
	AddBreak("12:00:00", "13:00:00", "Lunch")
	AddHoliday("2024-10-05", "Independence Day")

	aStats = Stats()

	? aStats[1][2]
	#--> 31

	? aStats[2][2]
	#--> 19

	? aStats[3][2]
	#--> 1

	? aStats[5][2]
	#--> 152
}

pf()
# Executed in 0.15 second(s) in Ring 1.24

#------------------------------------------#
#  Copying and Cloning                     #
#------------------------------------------#

/*--- Creating independent calendar copy

pr()

oCal1 = new stzCalendar([2024, 10])
oCal1.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])

oCal2 = oCal1.Copy()

oCal2.NextMonth()

? oCal1.Current()
#--> October 2024

? oCal2.Current()
#--> November 2024

? oCal1.Clone().Current()
#--> October 2024

pf()
# Executed in 0.01 second(s) in Ring 1.24

#------------------------------------------#
#  Content and Display                     #
#------------------------------------------#

/*--- Getting calendar content as hash

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
	AddHoliday("2024-10-05", "Independence Day")
	SetBusinessHours("09:00:00", "17:00:00")

	aContent = Content()

	? aContent[1][2]
	#--> 2024-10-01

	? aContent[2][2]
	#--> 2024-10-31

	? aContent[3][2]
	#--> 2024

	? aContent[4][2]
	#--> 10

	? len(aContent[7][2])
	#--> 1
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Displaying calendar details

pr()

oCal = new stzCalendar([2024, 10])

oCal {
	SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
	SetBusinessHours("09:00:00", "17:00:00")
	AddBreak("12:00:00", "13:00:00", "Lunch")
	AddHoliday("2024-10-05", "Independence Day")

	Show()
}

pf()
# Executed in 0.03 second(s) in Ring 1.24
