load "../stzbase.ring"


/*--- Calling Today() and Creating a date object from today

pr()

? Today()
#--> 27/09/2025

oDate = TodayQ()
? oDate.Content() # Or ToString()
#--> 27/09/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating a date from string

pr()

oDate = StzDateQ("15/03/2024")
? oDate.Content()
#--> 15/03/2024

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting current date and time

pr()

? Now()
#--> 27/09/2025 14:30:25

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Adding days to a date

pr()

oDate = StzDateQ("01/01/2025")
oDate.AddDays(30)
? oDate.Content()
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

/*--- Calculating days between dates

pr()

oDate1 = StzDateQ("01/01/2025")
oDate2 = StzDateQ("31/12/2025")

? oDate1.DaysTo(oDate2)
#--> 364

# Or better:
? oDate2 - oDate1

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
? oDate1 < "20/06/2024"

? ""

? oDate1 > oDate2
? oDate1 > "20/06/2024"

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---
*/
pr()
Rx = new stzRegex(pat(:IsoDate))
? Rx.Match("20-10-2025")

? IsDate("20/10/20025")
#--> FALSE

? IsDate("20/10/2025")
#--> TRUE

//? QQ("20/10/2025") = "20-10-2025"

pf()

/*--- Formatting dates in different styles

pr()

oDate = StzDateQ("15/07/2024")

? "European: " + oDate.ToEuropean()
? "American: " + oDate.ToAmerican()
? "ISO8601: " + oDate.ToISO8601()
? "Custom format: " + oDate.ToStringXT("dddd, MMMM d, yyyy")
#--> European: 15/07/2024
#--> American: 07/15/2024
#--> ISO8601: 2024-07-15
#--> Custom format: Monday, July 15, 2024

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Using named formats

pr()

oDate = StzDateQ("25/12/2024")
? "Long format: " + oDate.ToStringXT(:Long)
? "Compact format: " + oDate.ToStringXT(:Compact)
#--> Long format: Wednesday, December 25, 2024
#--> Compact format: 25122024

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting week number

pr()

oDate = StzDateQ("15/07/2024")
? "Week number: " + oDate.WeekNumber()
#--> Week number: 29

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Date validation

pr()

try
    oDate = StzDateQ("32/13/2024")  # Invalid date
    ? oDate.Content()
catch
    ? "Invalid date detected and handled"
done
#--> Invalid date detected and handled

pf()
# Executed in almost 0 second(s) in Ring 1.23
