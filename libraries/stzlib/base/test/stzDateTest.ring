load "../stzbase.ring"


/*--- Calling Today() and Creating a date object from today

pr()

? Today()
#--> 27/09/2025

oDate = TodayQ()
? oDate.ToString()
#--> 27/09/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Creating a date from string

pr()

oDate = StzDateQ("15/03/2024")
? oDate.ToString()
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
? oDate.ToString()
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
? oDate.DayIn(:French)
? oDate.DayIn(:Arabic)
#--> Saturday
#--> Samedi
#o--> السبت

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting month name in different languages

pr()

oDate = StzDateQ("15/03/2024")

? oDate.Month()
? oDate.MonthIn(:French)
? oDate.MonthIn(:Arabic)
#--> March
#--> Mars
#o--> مارس

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting various date components

pr()

oDate = StzDateQ("15/07/2024")

? "Year: " + oDate.Year()
? "Month number: " + oDate.MonthNumberInString()
? "Day number: " + oDate.DayNumberInString()
? "Day of week: " + oDate.DayOfWeek()
? "Day of year: " + oDate.DayOfYear()
#--> Year: 2024
#--> Month number: 7
#--> Day number: 15
#--> Day of week: 1
#--> Day of year: 197

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Checking if year is leap year

pr()

oDate1 = StzDateQ("15/02/2024")
oDate2 = StzDateQ("15/02/2025")

? "2024 is leap year: " + oDate1.IsLeapYear()
? "2025 is leap year: " + oDate2.IsLeapYear()
#--> 2024 is leap year: true
#--> 2025 is leap year: false

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Getting days in month and year

pr()

oDate = StzDateQ("15/02/2024")

? "Days in February 2024: " + oDate.DaysInMonth()
? "Days in year 2024: " + oDate.DaysInYear()
#--> Days in February 2024: 29
#--> Days in year 2024: 366

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Calculating days between dates

pr()

oDate1 = StzDateQ("01/01/2025")
oDate2 = StzDateQ("31/12/2025")

nDays = oDate1.DaysTo(oDate2)
? "Days from start to end of 2025: " + nDays
#--> Days from start to end of 2025: 364

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Comparing dates

pr()
oDate1 = StzDateQ("15/06/2024")
oDate2 = StzDateQ("20/06/2024")

? "June 15 is before June 20: " + oDate1.IsBefore(oDate2)
? "June 20 is after June 15: " + oDate2.IsAfter(oDate1)
? "June 15 equals June 20: " + oDate1.IsEqual(oDate2)
#--> June 15 is before June 20: true
#--> June 20 is after June 15: true
#--> June 15 equals June 20: false

pf()
# Executed in almost 0 second(s) in Ring 1.23

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
*/
pr()

oDate = StzDateQ("15/07/2024")
? "Week number: " + oDate.WeekNumber()
#--> Week number: 29

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Working with timestamps
pr()
? "Current timestamp: " + TimeStamp()
? "Unix timestamp: " + UnixTimeStamp()
? "Custom timestamp: " + TimeStamp("yyyy-MM-dd_HH-mm-ss")
#--> Current timestamp: 27/09/2025 14:30:25
#--> Unix timestamp: 1759276225
#--> Custom timestamp: 2025-09-27_14-30-25
pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Chaining operations with Q methods
pr()
oDate = StzDateQ("01/01/2024")
cResult = oDate.AddDaysQ(30).AddMonthsQ(2).ToString()
? cResult
#--> 31/03/2024
pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Setting and using different languages
pr()
SetLanguage(:French)
oDate = StzDateQ("14/07/2024")
? "French day: " + oDate.Day()
? "French month: " + oDate.Month()

SetLanguage(:Arabic)
? "Arabic day: " + oDate.Day()
? "Arabic month: " + oDate.Month()
#--> French day: Dimanche
#--> French month: Juillet
#--> Arabic day: الأحد
#--> Arabic month: يوليو
pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Date validation
pr()
try
    oDate = StzDateQ("32/13/2024")  # Invalid date
    ? oDate.ToString()
catch
    ? "Invalid date detected and handled"
done
#--> Invalid date detected and handled
pf()
# Executed in almost 0 second(s) in Ring 1.23
