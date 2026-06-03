load "../stzbase.ring"

/*--- Calling Today() and Creating a date object from today

pr()

? Today()
#--> 27/09/2025

oDate = TodayQ()
? oDate.Date() # Or ToString()
#--> 27/09/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating an empty stzDate object and then setting the date

pr()

o1 = new stzDate("")
? o1.Date()
#--> 10/10/2025

? o1.ToHuman() + NL
#--> today

#--

o1.SetDate(Tomorrow())
? o1.Date()
#--> 11/10/2025

? o1.ToHuman()
#--> tomorrow

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Creating a date from string

pr()

oDate = StzDateQ("15/03/2024") # Or 2024-03-15
? oDate.Date()
#--> 15/03/2024		# Format by deafult, can be changed

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating a date objectfrom list of numbers

pr()

o1 = new stzDate([ 2024, 10, 10 ])
? o1.Date()
#--> 10/10/2024

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Createing a date object from a hashlist in any order

pr()

o1 = new stzDate([ :Day = 12, :Month = 10, :Year = 2024 ])
? o1.Date()
#--> 12/10/2024

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*---

pr()

? Today() #--> 10/10/2025

o1 = new stzDate("In 15 days")
? o1.Date() #--> 25/10/2025
? o1.ToHuman()
#--> Saturday, October 25th, 2025

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*=== Getting current date and time

pr()

? Now() # Default format
#--> 27/09/2025 14:30:25

? NowXT() # ISO format
#--> 2025-26-10 14:26:38

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Adding days to a date

pr()

oDate = StzDateQ("01/01/2025")
oDate.AddDays(30)
? oDate.Date()
#--> 31/01/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Using operator overloading to add days

pr()

oDate = StzDateQ("01/01/2025")
? oDate + 15
#--> 16/01/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Adding months and years

pr()

oDate = StzDateQ("15/06/2024")
oDate { AddMonths(3) AddYears(1) ? ToString() }
#--> 15/09/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Subtracting days using operator

pr()

oDate = StzDateQ("20/12/2024")
? oDate - 10
#--> 10/12/2024

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Using string operations for date arithmetic

pr()

oDate = new stzDate("01/01/2025")
? oDate + "2 months"
#--> 01/03/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting day name in different languages

pr()

oDate = StzDateQ("27/09/2025")

? oDate.Day()
#--> Saturday

? oDate.DayIn(:French)
#--> Samedi

? oDate.DayIn(:Arabic)
#o--> السبت

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting month name in different languages

pr()

oDate = StzDateQ("15/03/2024")

? oDate.Month()
#--> March

? oDate.MonthIn(:French)
#--> Mars

? oDate.MonthIn(:Arabic)
#o--> مارس

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting various date components

pr()

oDate = StzDateQ("15/07/2024")
oDate {

	? Year()
	#--> 2024

	? MonthNumber()
	#--> 7

	? DayNumber()
	#--> 15

	? DayOfWeek()
	#--> 1

	? DayOfYear()
	#--> 197

}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Checking if year is leap year

pr()

? StzDateQ("15/02/2024").IsLeapYear()
#--> TRUE

? StzDateQ("15/02/2025").IsLeap()
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting days in month and year

pr()

oDate = StzDateQ("15/02/2024")

? oDate.DaysInMonth()
#--> 29

? oDate.DaysInYear()
#--> 366

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Calculating days, months and years between dates
*/
pr()

oDate1 = StzDateQ("01/01/2025")
oDate2 = StzDateQ("31/12/2027")

? oDate1.DaysToN(oDate2)
#--> 1094

# Or better:
? oDate2 - oDate1
#--> 1094

? oDate1.MonthsToN(oDate2)
#--> 35

? oDate1.YearsToN(oDate2)
#•--> 2

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Checking if a date is between two other dates

pr()

oYesterday = new stzDate(:Yesterday)
oToday = new stzDate(:Today)
oTomorrow = new stzDate(:Tomorrow)

? oToday.IsBetween(oYesterday, :And = oTomorrow)
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Comparing dates

pr()

oDate1 = StzDateQ("15/06/2024")
oDate2 = StzDateQ("20/06/2024")

? oDate1.IsBefore(oDate2)
#--> TRUE

? oDate2.IsAfter(oDate1)
#--> TRUE

? oDate1.IsEqual(oDate2)
#--> FALSE

# Or Better
? ""

? oDate1 < oDate2
#--> TRUE

? oDate1 < "20/06/2024"
#--> TRUE

? ""

? oDate1 > oDate2
#--> FALSE

? oDate1 > "20/06/2024"
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---
pr()

Rx = new stzRegex(pat(:Date))
? Rx.Match("20-10-2025")

? IsDate("20/10/20025")
#--> FALSE

? IsDate("20/10/2025")
#--> TRUE

? QQ("20/10/2025").IsEqualTo("20-10-2025")
#--> TRUE

? QQ("20/10/2025") = "20-10-2025"
#--> TRUE

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*--- Formatting dates in different styles
*/
pr()

oDate = StzDateQ("15/07/2024")

? oDate.ToEuropean()
#--> 15/07/2024

? oDate.ToAmerican()
#--> 07/15/2024

? oDate.ToISO8601()
#--> 2024-07-15

? oDate.ToStringXT("dddd, MMMM d, yyyy") # Custom format
#--> Monday, July 15, 2024

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Using named formats

pr()

oDate = StzDateQ("25/12/2024")

? oDate.ToStringXT(:Long)
#--> Wednesday, December 25, 2024

? oDate.ToStringXT(:Compact)
#--> 25122024

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting week number

pr()

? StzDateQ("15/07/2024").WeekNumber()
#--> 29

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Date validation

pr()

oDate = StzDateQ("32/13/2024")  # Invalid date
#--> Cannot parse date string: 32/13/2024

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Calculating Age

pr()

# Traditional approach requires complex date math
# stzDate approach
oBirthday = StzDateQ("15/06/1990")
? oBirthday.Age()  # Automatic calculation
#--> 35

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

o1 = new stzDate(:Today)

? o1.Date()		#--> 30/09/2025
? o1.ToHuman()	+ NL	#--> today

o1 + "1 day"
? o1.Date()		#--> 01/10/2025
? o1.ToHuman() + NL	#--> tomorrow

o1 - "2 days"
? o1.Date()		#--> 29/09/2025
? o1.ToHuman() + NL	#--> yesterday

o1 + "2 weeks"
? o1.Date()		#--> 13/10/2025
? o1.ToRelative()	#--> in 1 week

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*---

pr()

o1 = new stzDate("10/12/2024")

? o1.Day()
#--> Tuesday

? o1.Month()
#--> December

? o1.ToHuman()
#--> Tuesday, December 10th, 2024

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*=== Julian day

/*--- Convert current date to Julian day number

pr()

o1 = new stzDate("2025-10-10")
? o1.ToJulianDay()
#--> 2460959

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Create a date from a Julian day number

pr()

o1 = new stzDate("")
o1.FromJulianDay(2460959)
? o1.Content()
#--> 16/09/2024	(the corresponding Gregorian date)

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Navigation methods

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
